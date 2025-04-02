--!strict
--!optimize 2
--!native

-- roDSMS.luau (Roblox Data Store Management System)
-- Provides everything needed to manage a data store in roblox.

-----------Dependecies-------------
-- bufferTypeRegistry.luau       --
-- queue.luau                    --
-----------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local bufferTypeRegistry = require(ReplicatedStorage.SharedScripts.bufferTypeRegistry)
local configs = require(script.Parent.dsConfig)

