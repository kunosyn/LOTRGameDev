--!strict
--!nolint LocalShadow

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Fusion = require(ReplicatedStorage.Packages.Fusion)

function SkillTree (
  scope: Fusion.Scope<typeof(Fusion)>,
  props: {
    shown: Fusion.UsedAs<boolean>
  }
): Instance
  local innerScope = scope:innerScope {
    SkillsDisplay = require(script.SkillsDisplay),
    SkillTreeTab = require(script.SkillTreeTab)
  }

  local currentSkillTree = scope:Value({
    Name = 'SKILL TREE',
    skills = { }
  })


  return scope:New 'ImageLabel' {
    Name = 'SkillTree',
    AnchorPoint = Vector2.new(.5, .5),

    Size = UDim2.fromScale(1, 1),
    Position = UDim2.fromScale(.5, .5),

    Image = 'rbxassetid://18180701174',


    [Fusion.Children] = {
      scope:New 'Frame' {
        Name = script.Name,

        AnchorPoint = Vector2.new(.5, .5),
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(.5, .5),

        BackgroundColor3 = Color3.fromHex '#333333',
        BackgroundTransparency = .4,

        [Fusion.Children] = {
          scope:New 'Frame' {
            AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.fromScale(.5, .5),

            Size = UDim2.fromScale(.8, .9),
            BackgroundTransparency = 1,

            
            [Fusion.Children] = {
              scope:New 'UIAspectRatioConstraint' {
                AspectRatio = 1.47
              },

              innerScope:SkillsDisplay({
                shown = props.shown
              }),

              innerScope:SkillTreeTab({
                currentSkillTree = currentSkillTree,
                shown = props.shown
              })
            }
          }
        }
      }
    }
  }
end


return SkillTree
