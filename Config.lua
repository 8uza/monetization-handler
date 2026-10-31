local Config = {}

-- this is the config for the system
-- if you want to add rewards for purchasing these products, head over to ShopInitializer

Config.Settings = {
	-- datastore name to save transaction data
	DataStoreName = "Shop_Transactions_v1",
	
	-- max purchases per time period
	MaxPurchasesPerMinute = 5,
	MaxPurchasesPerHour = 20,
	
	-- if it should print logs or not
	EnablePurchaseLogging = true,
}

Config.GamePasses = {
	-- examples:
	VIP = 1337,
	VIPplusplus = 7331	
	
}

Config.DeveloperProducts = {
	-- examples:
	Coins100 = 707,
	Cashgrab2 = 99999999
}

return Config