--!strict
--!nolint LocalShadow


local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Fusion = require(ReplicatedStorage.Packages.Fusion)


function AdminUi (
  scope: Fusion.Scope<typeof(Fusion)>,

  props: {
    confirmingBan: Fusion.UsedAs<boolean>,
    player: Fusion.UsedAs<Player>
  }
): Instance
  local innerScope = scope:innerScope {
    ConfirmBan = require(script.ConfirmBan)
  }


  return scope:New 'Frame' {
    Name = script.Name,
    AnchorPoint = Vector2.new(.5, .5),

    Position = UDim2.fromScale(.5, .5),
    Size = UDim2.fromScale(1, 1),

    BackgroundTransparency = 1,


    [Fusion.Children] = {
      innerScope:ConfirmBan({
        player = props.player,
        shown = props.confirmingBan
      })
    }
  }
end


return AdminUi
