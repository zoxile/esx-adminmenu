BanCache = {}
local translations
local bans = {}

function BanCache.load()
	-- Clear existing cache for ex. command usage.
	bans = {}

	local rows = MySQL.query.await("SELECT * FROM bans")
	if not rows then
		return
	end

	for i = 1, #rows do
		local ban = rows[i]
		local identifier = ban.identifier

		if not bans[identifier] then
			bans[identifier] = {}
		end

		bans[identifier][#bans[identifier] + 1] = ban
	end
end

function BanCache.get(identifier)
	print("Checking Identifier for ban:", identifier)

	local list = bans[identifier]
	if not list then
		return nil
	end

	local now = os.time()

	for i = #list, 1, -1 do
		local ban = list[i]

		if ban.expires_at then
			local expires

			if type(ban.expires_at) == "number" then
				if ban.expires_at > 1e12 then
					expires = math.floor(ban.expires_at / 1000)
				else
					expires = ban.expires_at
				end
			elseif type(ban.expires_at) == "string" then
				expires = os.time({
					year = tonumber(ban.expires_at:sub(1, 4)),
					month = tonumber(ban.expires_at:sub(6, 7)),
					day = tonumber(ban.expires_at:sub(9, 10)),
					hour = tonumber(ban.expires_at:sub(12, 13)),
					min = tonumber(ban.expires_at:sub(15, 16)),
					sec = tonumber(ban.expires_at:sub(18, 19)),
				})
			end

			if expires and now >= expires then
				table.remove(list, i)
			else
				if expires then
					local remaining = expires - now
					ban.remaining_seconds = remaining
					ban.remaining_formatted = Helpers.formatRemainingTime(remaining)
				end

				return ban
			end
		else
			ban.remaining_formatted = Helper.getTranslation("permanent")
			return ban
		end
	end

	if #list == 0 then
		bans[identifier] = nil
	end

	return nil
end

function BanCache.add(ban)
	if not bans[ban.identifier] then
		bans[ban.identifier] = {}
	end

	bans[ban.identifier][#bans[ban.identifier] + 1] = ban
end

function BanCache.updateExpiry(identifier, newExpiry)
	local list = bans[identifier]
	if not list then
		return
	end

	for i = #list, 1, -1 do
		local ban = list[i]
		ban.expires_at = newExpiry
		return
	end
end

-- No need for this at the moment but in case the logic changes this might be useful.
function BanCache.expireNow(identifier)
	local list = bans[identifier]
	if not list then
		return
	end

	local now = os.time()

	for i = #list, 1, -1 do
		local ban = list[i]
		ban.expires_at = now
	end
end

function BanCache.getAll()
	return bans
end

return BanCache
