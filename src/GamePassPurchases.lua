local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local GamePassPurchases = {}
GamePassPurchases.__index = GamePassPurchases

function GamePassPurchases.new(config, logger)
	local self = setmetatable({}, GamePassPurchases)

	self.Config = config
	self.Callbacks = {}
	self.Applied = {}
	self.Logger = logger

	return self
end

function GamePassPurchases:Setup(name, callback)
	local passId = self.Config.GamePasses[name]

	assert(passId, "Unknown Game Pass: " .. tostring(name))
	assert(typeof(callback) == "function", "Callback must be a function")

	self.Callbacks[passId] = {
		Name = name,
		Callback = callback,
	}

	return true
end

function GamePassPurchases:Owns(player, name)
	local passId = self.Config.GamePasses[name]

	if not passId then
		return false, "Unknown Game Pass"
	end

	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(
			player.UserId,
			passId
		)
	end)

	if not success then
		return false, result
	end

	return result
end

function GamePassPurchases:Apply(player, passId)
	local entry = self.Callbacks[passId]

	if not entry then
		return
	end

	local userId = player.UserId

	self.Applied[userId] = self.Applied[userId] or {}

	if self.Applied[userId][passId] then
		return
	end

	local success, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(
			userId,
			passId
		)
	end)

	if not success or not owns then
		return
	end

	local callbackSuccess, err = pcall(entry.Callback, player)

	if callbackSuccess then
		self.Applied[userId][passId] = true

		self.Logger("Game Pass activated:", entry.Name, player.Name)
	else
		warn("[SecureShop] Game Pass callback failed:", err)
	end
end

function GamePassPurchases:Initialize()
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(
		function(player, passId, purchased)
			if purchased then
				self:Apply(player, passId)
			end
		end
	)

	Players.PlayerAdded:Connect(function(player)
		for passId in pairs(self.Callbacks) do
			task.spawn(function()
				self:Apply(player, passId)
			end)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		self.Applied[player.UserId] = nil
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		for passId in pairs(self.Callbacks) do
			task.spawn(function()
				self:Apply(player, passId)
			end)
		end
	end
end

function GamePassPurchases:Prompt(player, name)
	local passId = self.Config.GamePasses[name]

	if not passId then
		return false, "Unknown Game Pass"
	end

	local success, err = pcall(function()
		MarketplaceService:PromptGamePassPurchase(player, passId)
	end)

	if not success then
		return false, err
	end

	return true
end

return GamePassPurchases