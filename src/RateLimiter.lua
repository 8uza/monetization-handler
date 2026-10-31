local RateLimiter = {}
RateLimiter.__index = RateLimiter

function RateLimiter.new(settings)
	local self = setmetatable({}, RateLimiter)

	self.Settings = settings
	self.Players = {}

	return self
end

function RateLimiter:Allow(player)
	local userId = player.UserId
	local now = os.time()

	local data = self.Players[userId]

	if not data then
		data = {
			Minute = 0,
			Hour = 0,
			MinuteWindow = math.floor(now / 60),
			HourWindow = math.floor(now / 3600),
		}

		self.Players[userId] = data
	end

	local minuteWindow = math.floor(now / 60)
	local hourWindow = math.floor(now / 3600)

	if data.MinuteWindow ~= minuteWindow then
		data.Minute = 0
		data.MinuteWindow = minuteWindow
	end

	if data.HourWindow ~= hourWindow then
		data.Hour = 0
		data.HourWindow = hourWindow
	end

	if data.Minute >= self.Settings.MaxPurchasesPerMinute then
		return false
	end

	if data.Hour >= self.Settings.MaxPurchasesPerHour then
		return false
	end

	data.Minute += 1
	data.Hour += 1

	return true
end

function RateLimiter:RemovePlayer(player)
	self.Players[player.UserId] = nil
end

return RateLimiter