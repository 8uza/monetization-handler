local DataStoreService = game:GetService("DataStoreService")

local TransactionManager = {}
TransactionManager.__index = TransactionManager

function TransactionManager.new(storeName)
	local self = setmetatable({}, TransactionManager)

	self.Store = DataStoreService:GetDataStore(storeName)
	self.Busy = {}

	return self
end

function TransactionManager:Process(purchaseId, callback)
	if self.Busy[purchaseId] then
		return false
	end

	self.Busy[purchaseId] = true

	local key = "Receipt_" .. tostring(purchaseId)
	local owner = game.JobId ~= "" and game.JobId or "Studio"
	local now = os.time()

	local success, record = pcall(function()
		return self.Store:UpdateAsync(key, function(old)
			if old and old.Status == "Granted" then
				return old
			end

			if old and old.Status == "Processing"
				and old.LeaseUntil
				and old.LeaseUntil > now then
				return old
			end

			return {
				Status = "Processing",
				Owner = owner,
				LeaseUntil = now + 120,
			}
		end)
	end)

	if not success then
		self.Busy[purchaseId] = nil
		warn("[SecureShop] Failed to reserve receipt:", record)
		return false
	end

	if record.Status == "Granted" then
		self.Busy[purchaseId] = nil
		return true
	end

	if record.Status ~= "Processing" or record.Owner ~= owner then
		self.Busy[purchaseId] = nil
		return false
	end

	local callbackSuccess, callbackResult = pcall(callback)

	if not callbackSuccess or callbackResult == false then
		pcall(function()
			self.Store:UpdateAsync(key, function(old)
				if old and old.Owner == owner
					and old.Status == "Processing" then
					return {
						Status = "Pending",
					}
				end

				return old
			end)
		end)

		self.Busy[purchaseId] = nil

		warn("[SecureShop] Reward processing failed:", callbackResult)

		return false
	end

	local saveSuccess, savedRecord = pcall(function()
		return self.Store:UpdateAsync(key, function(old)
			if old and old.Status == "Granted" then
				return old
			end

			if old and old.Owner == owner
				and old.Status == "Processing" then
				return {
					Status = "Granted",
					GrantedAt = os.time(),
				}
			end

			return old
		end)
	end)

	self.Busy[purchaseId] = nil

	if not saveSuccess or not savedRecord
		or savedRecord.Status ~= "Granted" then
		warn("[SecureShop] Could not save completed receipt:", purchaseId)
		return false
	end

	return true
end

return TransactionManager