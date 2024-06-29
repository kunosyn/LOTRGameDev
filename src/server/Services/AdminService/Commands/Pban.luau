--!strict
--!nolint LocalShadow

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local Command = require(script.Parent.Parent.Command)
local Globals = require(ReplicatedStorage.Source.Libraries.Globals)

local Utility = ServerScriptService.Source.Utility
local types = require(Utility.Types)


type AdminServiceT = types.AdminServiceT
type CommandT = types.CommandT
type CommandExecutionStatusT = types.CommandExecutionStatusT


return function (AdminService: AdminServiceT)
    local PermBanCommand: CommandT = Command.new(
        'permban',
        AdminService,

        { 
            CommandSecondaryAlias = '/pban', 
            AutoCompleteIfHasPermissions = true 
        }
    )


    PermBanCommand.Permissions = {
        Any = true
    }

    function PermBanCommand:Callback (player: Player, ...: string): CommandExecutionStatusT
        local args: { string } = { ... }
        if #args < 1 then return Command.Error('No username entered.') end

        local target: Player? = Globals:GetPlayerFromPartialName(args[1])
        local reason: string?

        if #args > 1 then
            reason = table.concat(args, ' ', 1)
        end

        if not target then
            return Command.Error('User is not in the game.')
        elseif target == player then
            return Command.Error('You cannot permban yourself.')
        end

        local success,err = AdminService:Ban(player, -1, reason)


        if success then
            AdminService:LogCommand(player, self.Name, target, reason)

            return Command.Success()
        else
            return Command.Error('Could not ban player.', err)
        end
    end

    AdminService:RegisterCommand(PermBanCommand)
end
