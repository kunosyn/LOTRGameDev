--!strict
--!nolint LocalShadow


local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Fusion = require(ReplicatedStorage.Packages.Fusion)


function Button (
  scope: Fusion.Scope<typeof(Fusion)>,
  
  props: {
    Visible: Fusion.UsedAs<boolean>,
    AnchorPoint: Vector2,
    Size: UDim2,
    Position: UDim2,

    BackgroundColor3: Color3,
    StrokeColor3: Color3,
    StrokeThickness: Color3,

    Image: string?,
    BackgroundTransparency: number?,
    StrokeTransparency: number?,
    Name: string?,

    CornerRadius: UDim?,
    TextColor3: Color3?
  }
): Instance
  return scope:New 'TextButton' {
    Name = props.Name or script.Name,
    Visible = props.Visible,
    
    AnchorPoint = props.AnchorPoint,
    Size = props.Size,
    Position = props.Position,

    BackgroundColor3 = props.BackgroundColor3,
    BackgroundTransparency = props.BackgroundTransparency,

    
    [Fusion.Children] = {
      scope:New 'UIStroke' {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = props.StrokeColor3,
        Thickness = props.StrokeThickness or 0
      },

      scope:New 'UICorner' {
        CornerRadius = props.CornerRadius or UDim.new(0, 0)
      },


      scope:New 'Frame' {
        BackgroundTransparency = 1,

        AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromScale(1, 1),


        [Fusion.Children] = {
          scope:New 'UIStroke' {
            Thickness = props.StrokeThickness,
            Transparency = props.StrokeTransparency,
            Color = props.StrokeColor3
          },

          scope:New 'UICorner' {
            CornerRadius = props.CornerRadius or UDim.new(0, 0)
          },

          scope:New 'ImageLabel' {
            Image = props.Image,
            AnchorPoint = Vector2.new(0, .5),
            Visible = props.Image ~= nil,

            Position = UDim2.fromScale(.05, .5),
            Size = UDim2.fromScale(0.245, 1.18),

            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromHex '#ffffff',


            [Fusion.Children] = {
              scope:New 'UIAspectRatioConstraint' {
                AspectRatio = 1
              }
            }
          },

          scope:New 'TextLabel' {
            AnchorPoint = if props.Image then Vector2.new(0, .5) else Vector2.new(.5, .5),
            BackgroundTransparency = 1,
            Position = if props.Image then UDim2.fromScale(.25, .5) else UDim2.fromScale(.5, .5),

            Size = if props.Image then UDim2.fromScale(.7, 1) else UDim2.fromScale(1, 1),
            FontFace = Font.fromName 'Balthazar',
            TextColor3 = props.TextColor3 or Color3.fromHex '#ffffff'
          }
        }
      }
    }
  }
end


return Button
