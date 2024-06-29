--!strict
--!nolint LocalShadow

local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Command = require(script.Parent.Parent.Command)
local Globals = require(ReplicatedStorage.Source.Libraries.Globals)

local Utility = ServerScriptService.Source.Utility
local types = require(Utility.Types)


type AdminServiceT = types.AdminServiceT
type CommandT = types.CommandT
type CommandExecutionStatusT = types.CommandExecutionStatusT


return function(AdminService: AdminServiceT)
  local TimeBanCommand: CommandT = Command.new(
    'timeban',
    AdminService,

    {
      CommandSecondaryAlias = '/tban',
      AutoCompleteIfHasPermissions = true,
    }
  )

  TimeBanCommand.Permissions = {
    Any = true
  }


  function TimeBanCommand:Callback (player: Player, ...: string): CommandExecutionStatusT
    local args: { string } = { ... }
    if #args < 1 then 
      return Command.Error('No username entered.') 
    elseif #args < 2 then
      return Command.Error('No time specified.')
    end

    local target = Globals:GetPlayerFromPartialName(args[1])
    local duration, durationString = Globals:GetTimeInSecondsFromString(args[2])
    local reason = table.concat(args, ' ', 3)

    if not target then
      return Command.Error('Player is not in the game.')
    end

    if duration == 0 then
      return Command.Error('Invalid ban duration.')
    end

    AdminService:Ban(target, duration, if #reason > 1 then reason else `You have been banned by {player.Name} for breaking the rules.`)
    AdminService:LogCommand(player, self.Name, target, if #reason > 1 then reason else nil, durationString)

    return Command.Success()
  end

  AdminService:RegisterCommand(TimeBanCommand)
end
