--!strict
--!nolint LocalShadow


local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Fusion = require(ReplicatedStorage.Packages.Fusion)


function SkillsDisplay (
  scope: Fusion.Scope<typeof(Fusion)>,
  props: {
    shown: Fusion.UsedAs<boolean>
  }
): Instance
  return scope:New 'Frame' {
    Name = script.Name,
    Visible = props.shown,
    
    AnchorPoint = Vector2.new(.5, 1),
    Size = UDim2.fromScale(.8, .7),
    Position = UDim2.fromScale(.5, .85),

    BackgroundColor3 = Color3.fromHex '#0b0c0e',
    BackgroundTransparency = .1,

    
    [Fusion.Children] = {
      scope:New 'UIStroke' {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromHex '#2c2e36',
        Thickness = 3.5
      },

      scope:New 'UICorner' {
        CornerRadius = UDim.new(0, 6)
      }
    }
  }
end


return SkillsDisplay
