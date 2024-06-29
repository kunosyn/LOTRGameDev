--!strict
--!nolint LocalShadow


local ServerScriptService = game:GetService('ServerScriptService')
local Services = ServerScriptService.Source.Services

local module = { }

local AdminService = require(Services.AdminService)
export type AdminServiceT = typeof(AdminService)

local Command = require(Services.AdminService.Command)
export type CommandT = Command.Type
export type CommandExecutionStatusT = Command.CommandExecutionStatusT


return module
