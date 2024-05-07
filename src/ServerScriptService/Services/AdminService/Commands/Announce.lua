local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local Command = require(script.Parent.Parent.Command)

return function(AdminService)
    local MessageCommand: Command.Command = Command.new('announce', AdminService, { CommandSecondaryAlias = '/a', AutoCompleteIfHasPermissions = true })

    MessageCommand.Permissions = {
        Any = true
    }

    function MessageCommand:Callback(player: Player, args: { string }): boolean
        local message: { string } = table.concat(args, ' ')
        
        local success,errorMessage = pcall(function()
            message = TextService:FilterStringAsync(message, player.UserId)
        end)

        if success then
            AdminService:ExecuteClientLogic(nil, 'Message', { player, message:GetNonChatStringForBroadcastAsync() })
            return { Success = true }
        else
            warn(errorMessage)
            return { Exception = true, Message = 'Message failed to send.' }
        end
    end

    table.insert(AdminService.Commands, MessageCommand)
end