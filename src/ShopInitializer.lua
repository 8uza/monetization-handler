local ServerScriptService = game:GetService("ServerScriptService")

local Shop = require(script:WaitForChild("Shop"))

-- developer products

Shop:SetupProductPurchase("Coins100", function(player, receiptInfo)
	print("Purchased 100 coins for " .. player.Name)

	-- here you put your code to give the player 100 coins or do something else
	
	return true
end)

Shop:SetupGamePassPurchase("VIP", function(player, receiptInfo)
	print("Purchased VIP for " .. player.Name)

	-- here you put your code to give the player 100 coins or do something else

	return true
end)


-- initialize, better to setup gamepasses or products before initializing

Shop:Initialize()