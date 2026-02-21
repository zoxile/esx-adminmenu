-- Initiate the database if it already doesn't exist.
local function initDB()
	--  BANS TABLE
	MySQL.query([[
        CREATE TABLE IF NOT EXISTS bans (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(64) NOT NULL,
            reason TEXT,
            banned_by VARCHAR(64),
            expires_at DATETIME NULL,
            banned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

            INDEX idx_bans_identifier (identifier),
            INDEX idx_bans_expires (expires_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

	--  KICKS TABLE
	MySQL.query([[
        CREATE TABLE IF NOT EXISTS kicks (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(64) NOT NULL,
            reason TEXT,
            kicked_by VARCHAR(64),
            kicked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

            INDEX idx_kicks_identifier (identifier)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
	print("[esx-adminmenu] Database tables checked/created!")
end

AddEventHandler("onResourceStart", function(resource)
	if resource ~= GetCurrentResourceName() then
		return
	end
	initDB()
	BanCache.load()
end)
