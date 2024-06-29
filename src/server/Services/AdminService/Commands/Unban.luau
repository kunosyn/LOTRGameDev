--!strict
--!nolint LocalShadow

local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local Command = require(script.Parent.Parent.Command)
local Globals = require(ReplicatedStorage.Source.Libraries.Globals)

local Utility = ServerScriptService.Source.Utility
local types = require(Utility.Types)


type AdminServiceT = types.AdminServiceT
type CommandT = types.CommandT
type CommandExecutionStatusT = types.CommandExecutionStatusT


return function(AdminService: AdminServiceT)
  local UnbanCommand: CommandT = Command.new(
    'unban',
    AdminService,

    {
      AutoCompleteIfHasPermissions = true,
    }
  )

  UnbanCommand.Permissions = {
    Any = true
  }


  function UnbanCommand:Callback (player: Player, ...: string): CommandExecutionStatusT
    local args: { string } = { ... }
    if #args < 1 then return Command.Error('No UserId entered.') end

    local userId = tonumber(args[1])
    if not userId then return Command.Error('Invalid UserId entered.') end

    local success,err = pcall(function()
      Players:UnbanAsync({
        UserIds = { userId },
        ApplyToUniverse = true
      })
    end)

    local reason = table.concat(args, ' ', 2)

    if success then
      AdminService:LogCommand(player, self.Name, userId, if #reason > 1 then reason else nil)
      return Command.Success()
    else
      return Command.Error('Could not unban player.', err)
    end
  end

  AdminService:RegisterCommand(UnbanCommand)
end
