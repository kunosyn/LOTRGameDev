--!strict
--!nolint LocalShadow

local TextService = game:GetService('TextService')
local ServerScriptService = game:GetService('ServerScriptService')
local Command = require(script.Parent.Parent.Command)

local Utility = ServerScriptService.Source.Utility
local types = require(Utility.Types)


type AdminServiceT = types.AdminServiceT
type CommandT = types.CommandT
type CommandExecutionStatusT = types.CommandExecutionStatusT


return function(AdminService: AdminServiceT)
    local MessageCommand: CommandT = Command.new(
        'announce',
        AdminService,

        { 
            CommandSecondaryAlias = '/a', 
            AutoCompleteIfHasPermissions = true 
        }
    )


    MessageCommand.Permissions = {
        Any = true
    }

    function MessageCommand:Callback (player: Player, ...: string): CommandExecutionStatusT
        local args: { string } = { ... }
        local message: string = table.concat(args, ' ')

        local filtered: TextFilterResult
        local success, errorMessage = pcall(function()
            filtered = TextService:FilterStringAsync(message, player.UserId)
        end)

        if success then
            AdminService:ExecuteClientLogic(nil, 'Message', player, filtered:GetNonChatStringForBroadcastAsync())

            AdminService:LogCommand(player, self.Name, nil, message)
            return Command.Success()
        else
            warn(errorMessage)
            return Command.Error('Message failed to send.')
        end
    end

    AdminService:RegisterCommand(MessageCommand)
end
