--!strict
--!nolint LocalShadow

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Knit = require(ReplicatedStorage.Packages.Knit)


local AntiCheatController = {
  Name = 'AntiCheatController'
}

function AntiCheatController:KnitStart ()
  self:ConnectEvents()
end

function AntiCheatController:ConnectEvents ()
  RunService.RenderStepped:Connect(function(delta: number) 
    self:CheckForInjection()
  end)
end

function AntiCheatController:CheckForInjection ()
  for _,v in getfenv() do
    if type(v) == 'function' and string.find(debug.info(v, 's') 'rbxasset') == nil then
      Knit.Player:Kick('Anti-Cheat detected possible script injection.')
    end
  end
end


return AntiCheatController
