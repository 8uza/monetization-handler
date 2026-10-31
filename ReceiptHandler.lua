local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local ReceiptHandler = {}
ReceiptHandler.__index = ReceiptHandler

function ReceiptHandler.new(products, transactions, logger)
	local self = setmetatable({}, ReceiptHandler)

	self.Products = products
	self.Transactions = transactions
	self.Logger = logger

	return self
end

function ReceiptHandler:ProcessReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)

	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local callback = self.Products:GetCallback(receiptInfo.ProductId)

	if not callback then
		warn("[SecureShop] No reward callback registered for product:",
			receiptInfo.ProductId)

		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local purchaseId = receiptInfo.PurchaseId

	if not purchaseId then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local success = self.Transactions:Process(
		purchaseId,
		function()
			return callback(player, receiptInfo)
		end
	)

	if success then
		self.Logger("Developer Product granted:",
			receiptInfo.ProductId, player.Name)

		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

function ReceiptHandler:Initialize()
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		return self:ProcessReceipt(receiptInfo)
	end
end

return ReceiptHandler