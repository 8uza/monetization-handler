local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(script.Parent.Config)

local Modules = script:WaitForChild("Modules")
local remoteFolder = ReplicatedStorage:WaitForChild("Remotes") -- change this to whatever location you want
local promptRemote = remoteFolder:WaitForChild("Prompt") -- this too if needed

local ProductPurchases = require(Modules.ProductPurchases)
local GamePassPurchases = require(Modules.GamePassPurchases)
local ReceiptHandler = require(Modules.ReceiptHandler)
local TransactionManager = require(Modules.TransactionManager)
local RateLimiter = require(Modules.RateLimiter)

local Shop = {}
Shop.__index = Shop

local initialized = false

local function Logger(...)
	if Config.Settings.EnablePurchaseLogging then
		print("[Shop] ", ...)
	end
end

local products = ProductPurchases.new(Config)
local gamePasses = GamePassPurchases.new(Config, Logger)

local transactions = TransactionManager.new(
	Config.Settings.DataStoreName
)

local rateLimiter = RateLimiter.new(Config.Settings)

local receipts = ReceiptHandler.new(
	products,
	transactions,
	Logger
)

function Shop:SetupProductPurchase(name, callback)
	return products:Setup(name, callback)
end

function Shop:SetupGamePassPurchase(name, callback)
	return gamePasses:Setup(name, callback)
end

function Shop:PromptProductPurchase(player, name)
	if not player or not player:IsA("Player") then
		return false, "Invalid player"
	end

	if not rateLimiter:Allow(player) then
		return false, "Purchase rate limit exceeded"
	end

	return products:Prompt(player, name)
end

function Shop:PromptGamePassPurchase(player, name)
	if not player or not player:IsA("Player") then
		return false, "Invalid player"
	end

	if not rateLimiter:Allow(player) then
		return false, "Purchase rate limit exceeded"
	end

	return gamePasses:Prompt(player, name)
end

function Shop:PlayerOwnsGamePass(player, name)
	return gamePasses:Owns(player, name)
end

function Shop:GetProductId(name)
	return Config.DeveloperProducts[name]
end

function Shop:GetGamePassId(name)
	return Config.GamePasses[name]
end

function Shop:Initialize()
	assert(not initialized, "already is initialized")

	initialized = true

	receipts:Initialize()
	gamePasses:Initialize()

	promptRemote.OnServerEvent:Connect(function(player, purchaseType, name)
		if typeof(name) ~= "string" then
			return
		end

		if string.lower(purchaseType) == "product" then
			self:PromptProductPurchase(player, name)

		elseif string.lower(purchaseType) == "gamepass" then
			self:PromptGamePassPurchase(player, name)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		rateLimiter:RemovePlayer(player)
	end)

	Logger("initialized successfully")

	return true
end

return setmetatable({}, Shop)

-- hi