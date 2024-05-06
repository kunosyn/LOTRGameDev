local Players = game:GetService("Players")
local Command = require(script.Parent.Parent.Command)

return function(AdminService)
    local PermBanCommand = Command.new('/permban', AdminService, { CommandSecondaryAlias = '/pban' })

    PermBanCommand.Permissions = {
        Any = true
    }

    function PermBanCommand:Callback(player: Player, args: { string }): boolean
        if #args < 1 then
            return { Exception = true, Message = 'No username entered.' }
        end

        local target: Player? = Players:FindFirstChild(args[1])

        if not target then
            return { Exception = true, Message = 'User is not in the game.' }
        end

        if target == player then
            return { Exception = true, Message = 'You cannot permban yourself.' }
        end

        AdminService:PermBan(player)
        target:Kick(AdminService.Config.BanMessage)

        return { Success = true }
    end
end