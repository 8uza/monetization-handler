local MarketplaceService = game:GetService("MarketplaceService")

local ProductPurchases = {}
ProductPurchases.__index = ProductPurchases

function ProductPurchases.new(config)
	local self = setmetatable({}, ProductPurchases)

	self.Config = config
	self.Callbacks = {}

	return self
end

function ProductPurchases:Setup(name, callback)
	local productId = self.Config.DeveloperProducts[name]

	assert(productId, "Unknown Developer Product: " .. tostring(name))
	assert(typeof(callback) == "function", "Callback must be a function")

	self.Callbacks[productId] = callback

	return true
end

function ProductPurchases:GetCallback(productId)
	return self.Callbacks[productId]
end

function ProductPurchases:Prompt(player, name)
	local productId = self.Config.DeveloperProducts[name]

	if not productId then
		return false, "Unknown Developer Product"
	end

	local success, err = pcall(function()
		MarketplaceService:PromptProductPurchase(player, productId)
	end)

	if not success then
		return false, err
	end

	return true
end

return ProductPurchases