local Players = game:GetService("Players")
local Command = require(script.Parent.Parent.Command)

return function(AdminService)
    local KickCommand = Command.new('kick', AdminService)

    KickCommand.Permissions = {
        Any = true
    }

    function KickCommand:Callback(player: Player, args: { string }): boolean
        if #args < 1 then
            return { Exception = true, Message = 'No username entered.' }
        end

        local target: Player? = Players:FindFirstChild(args[1])

        if not target then
            return { Exception = true, Message = 'User is not in the game.' }
        end

        if target == player then 
            return { Exception = true, Message = 'You cannot kick yourself.' }
        end

        
        target:Kick(if #args > 1 then `Kicked by {player.Name} - {table.concat(args, ' ', 2)}` else `You have been kicked from the game by {player.Name}.`)

        return { Success = true }
    end
end