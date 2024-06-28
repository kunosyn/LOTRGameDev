--!strict
--!nolint LocalShadow


local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local Fusion = require(ReplicatedStorage.Packages.Fusion)

function ConfirmBan (
  scope: Fusion.Scope<typeof(Fusion)>,

  props: {
    player: Fusion.UsedAs<Player>,
    shown: Fusion.UsedAs<boolean>
  }
): Instance
  local player: Player = Fusion.peek(props.player)


  return scope:New 'Frame' {
    Name = script.Name,
    AnchorPoint = Vector2.new(.5, .5),

    Size = UDim2.fromScale(.4, .25),
    Position = UDim2.fromScale(.5, .5),

    BackgroundColor3 = Color3.fromHex '#0b0c0e',
    BackgroundTransparency = .1,
    Visible = props.shown,


    [Fusion.Children] = {
      scope:New 'UIStroke' {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromHex '#16171b',
        Thickness = 2
      },

      scope:New 'UICorner' {
        CornerRadius = UDim.new(0, 6)
      },

      scope:New 'UIAspectRatioConstraint' {
        AspectRatio = 2
      },

      scope:New 'UISizeConstraint' {
        MinSize = Vector2.new(500, 150),
      },

      
      scope:New 'ImageLabel' {
        Size = UDim2.fromScale(.4, .4),
        Position = UDim2.fromScale(.05, .15),
        BackgroundTransparency =  1,

        Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),

        [Fusion.Children] = {
          scope:New 'UIAspectRatioConstraint' {
            AspectRatio = 1
          },

          scope:New 'UICorner' {
            CornerRadius = UDim.new(0, 4),
          }
        }
      },

      scope:New 'TextLabel' {
        BackgroundTransparency = 1,

        Size = UDim2.fromScale(.35, .1),
        Position = UDim2.fromScale(.05, .6),

        FontFace = Font.fromName 'Balthazar',
        
        Text = `{player.DisplayName} (@{player.Name})`,
        TextScaled = true,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Color3.fromHex '#ffffff'
      },


      scope:New 'TextLabel' {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1),

        Size = UDim2.fromScale(.45, .15),
        Position = UDim2.fromScale(.95, .15),

        FontFace = Font.fromName 'Balthazar',
        FontWeight = Enum.FontWeight.Bold,
        RichText = true,

        Text = `<b>Confirm Ban</b>`,
        TextColor3 = Color3.fromHex '#ffffff',

        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Right
      },

      scope:New 'TextLabel' {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1),

        Size = UDim2.fromScale(.5, .15),
        Position = UDim2.fromScale(.95, .3),

        FontFace = Font.fromName 'Balthazar',
        Text = `Are you sure you want to ban {player.Name}?`,
        TextScaled = true,

        TextXAlignment = Enum.TextXAlignment.Right,
        TextColor3 = Color3.fromHex '#d4d4d4'
      },

      scope:New 'Frame' {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1),

        Size = UDim2.fromScale(.5, .35),
        Position = UDim2.fromScale(.95, .47),

       [Fusion.Children] = {

       } 
      }
    }
  }
end


return ConfirmBan
