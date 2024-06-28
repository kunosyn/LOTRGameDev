--!strict
--!nolint LocalShadow


local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Fusion = require(ReplicatedStorage.Packages.Fusion)


function UIShadow (
  scope: Fusion.Scope<typeof(Fusion)>,

  props: { }
): Instance
  return scope:New 'Frame' {

  }
end


return UIShadow
