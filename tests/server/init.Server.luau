--
--!optimize 2

-- serverStarter.luau
-- This script is the entry point for the server. It is responsible for setting up the server environment and starting the server scripts.

-- local dsms = require(game.ServerScriptService.ServerScripts.roDSMS)

-- local ds = dsms(function(name, folder, del)

--     name("Test Data base")

--     folder(function(name, add, remove)
--         name("Folder 1")
--         add("Hello World")
--     end)


-- end)

local networking = require(game.ReplicatedStorage.SharedScripts.networking)

for i = 1, 255 do
    networking.packet(networking.types.bool)
end
