--!strict
--!nolint LocalShadow

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local Command = require(script.Parent.Parent.Command)
local Globals = require(ReplicatedStorage.Source.Globals)

local Utility = ServerScriptService.Source.Utility
local types = require(Utility.Types)


type AdminServiceT = types.AdminServiceT
type CommandT = types.CommandT
type CommandExecutionStatusT = types.CommandExecutionStatusT


return function (AdminService: AdminServiceT)
    local KickCommand: CommandT = Command.new(
        'kick',
        AdminService,

        { 
            AutoCompleteIfHasPermissions = true 
        }
    )


    KickCommand.Permissions = {
        Any = true
    }

    function KickCommand:Callback (player: Player, ...: string): CommandExecutionStatusT
        local args: { string } = { ... }
        if #args < 1 then return Command.Error('No username entered.') end

        local target: Player? = Globals:GetPlayerFromPartialName(args[1])
        if not target then return Command.Error('User is not in the game.') end

        if target == player then
            return Command.Error('You cannot kick yourself.')
        end

        local reason = table.concat(args, ' ', 2)
        target:Kick(if #args > 1 then `Kicked by {player.Name} - {reason}` else `You have been kicked from the game by {player.Name}.`)

        AdminService:LogCommand(player, self.Name, target, if #args > 1 then reason else nil)
        return Command.Success()
    end

    AdminService:RegisterCommand(KickCommand)
end
