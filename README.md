# Monetization Handler

A secure, server-side monetization framework for Roblox that handles Developer Products and Game Passes with transaction tracking, receipt handling, and purchase rate limiting.

## Features

- Developer Product purchases with automatic receipt processing
- Game Pass purchases with ownership checks
- Transaction history persisted to a DataStore (prevents lost purchases)
- Built-in rate limiting (max purchases per minute/hour per player)
- Client-to-server purchase prompts via a single RemoteEvent
- Optional purchase logging

## Installation

1. Move the `ServerScriptService` folder contents into `ServerScriptService`.
2. Move the `ReplicatedStorage` folder contents into `ReplicatedStorage`.
3. Add your Game Pass and Developer Product IDs to the `Config` ModuleScript.
4. Register purchase callbacks in `ShopInitializer` (see Usage).

The `Demo` folder contains an example setup you can reference or delete.

## Configuration

Edit `Config` (ModuleScript inside `ShopInitializer`):

- `Settings.DataStoreName` – DataStore used to save transaction data
- `Settings.MaxPurchasesPerMinute` / `MaxPurchasesPerHour` – rate limits
- `Settings.EnablePurchaseLogging` – toggles console logs
- `GamePasses` – map of names to Game Pass IDs (e.g. `VIP = 1337`)
- `DeveloperProducts` – map of names to Product IDs (e.g. `Coins100 = 707`)

## Usage

Register callbacks and initialize (server-side, in `ShopInitializer`):

```lua
local Shop = require(script:WaitForChild("Shop"))

Shop:SetupProductPurchase("Coins100", function(player, receiptInfo)
    -- give the player 100 coins
    return true -- mark the purchase as handled
end)

Shop:SetupGamePassPurchase("VIP", function(player, receiptInfo)
    -- grant VIP perks
    return true
end)

Shop:Initialize()
```

Prompt a purchase from the client:

```lua
local remote = game.ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("Prompt")

remote:FireServer("product", "Coins100") -- or "gamepass", "VIP"
```

## API

### Register a Developer Product

```lua
Shop:SetupProductPurchase(name, callback)
```

### Register a Game Pass

```lua
Shop:SetupGamePassPurchase(name, callback)
```

### Prompt a Developer Product Purchase

```lua
Shop:PromptProductPurchase(player, name)
```

### Prompt a Game Pass Purchase

```lua
Shop:PromptGamePassPurchase(player, name)
```

### Check Game Pass Ownership

```lua
Shop:PlayerOwnsGamePass(player, name)
```

### Get a Developer Product ID

```lua
Shop:GetProductId(name)
```

### Get a Game Pass ID

```lua
Shop:GetGamePassId(name)
```

### Initialize the Framework

```lua
Shop:Initialize()
```

## Structure

- `ReplicatedStorage/Remotes/Prompt` – RemoteEvent used by clients to request purchase prompts
- `ServerScriptService/ShopInitializer` – entry point script
- `ShopInitializer/Shop` – main framework module
- `ShopInitializer/Config` – user configuration
- `Shop/Modules` – GamePassPurchases, ProductPurchases, RateLimiter, ReceiptHandler, TransactionManager

## Notes

- Always return `true` from callbacks once the reward is granted, otherwise the receipt is retried on next join.
- Set up all products/game passes before calling `Shop:Initialize()`.
