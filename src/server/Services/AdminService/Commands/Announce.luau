--!strict
--!nolint LocalShadow

local TextService = game:GetService('TextService')
local Command = require(script.Parent.Parent.Command)

return function(AdminService)
    local MessageCommand: Command.Command = Command.new('announce', AdminService, { CommandSecondaryAlias = '/a', AutoCompleteIfHasPermissions = true })

    MessageCommand.Permissions = {
        Any = true
    }

    function MessageCommand:Callback (player: Player, ...): Command.CommandExecutionStatus
        local args: { string } = { ... }
        local message: string = table.concat(args, ' ')

        local filtered: TextFilterResult
        local success, errorMessage = pcall(function()
            filtered = TextService:FilterStringAsync(message, player.UserId)
        end)

        if success then
            AdminService:ExecuteClientLogic(nil, 'Message', player, filtered:GetNonChatStringForBroadcastAsync())

            self:Log(player, nil, message)
            return Command.Success()
        else
            warn(errorMessage)
            return Command.Error('Message failed to send.')
        end
    end

    table.insert(AdminService.Commands, MessageCommand)
end
