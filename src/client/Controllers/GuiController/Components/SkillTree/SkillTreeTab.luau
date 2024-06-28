--!strict
--!nolint LocalShadow


local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Fusion = require(ReplicatedStorage.Packages.Fusion)

function SideText (
  scope: Fusion.Scope<typeof(Fusion)>,

  props: { 
    AnchorPoint: Vector2,
    Position: UDim2,
    Text: string
  }
): Instance
  return scope:New 'TextButton' {
    Text = props.Text,
    FontFace = Font.fromName 'Balthazar',

    Size = UDim2.fromScale(.1, .2),
    TextScaled = true,

    Position = props.Position,
    AnchorPoint = props.AnchorPoint,

    BackgroundTransparency = 1,
    TextColor3 = Color3.fromHex '#ffffff',
  }
end

function TextBorder (
  scope: Fusion.Scope<typeof(Fusion)>,
  props: {
    AnchorPoint: Vector2,
    Position: UDim2
  }
)
  return scope:New 'TextLabel' {
    Text = '|',
    Font = Enum.Font.Arial,

    Size = UDim2.fromScale(.1, .25),
    TextScaled = true,
    
    Position = props.Position,
    AnchorPoint = props.AnchorPoint,

    BackgroundTransparency = 1,
    TextTransparency = .4,
    TextColor3 = Color3.fromHex '#212121'
  }
end

function Selection (
  scope: Fusion.Scope<typeof(Fusion)>,
  props: {
    Position: UDim2,
    Selected: Fusion.UsedAs<boolean>
  }
)
  return scope:New 'Frame' {
    AnchorPoint = Vector2.new(.5, .5),
    BackgroundTransparency = if props.Selected then 1 else 0,

    Size = UDim2.fromScale(.016, .021),
    Rotation = if props.Selected then 45 else 0,


    [Fusion.Children] = {
      scope:New 'UIStroke' {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromHex '#ffffff',
        LineJoinMode = Enum.LineJoinMode.Miter,
        Thickness = 1
      },

      scope:New 'UIAspectRatioConstraint' {
        AspectRatio = 1
      },

      scope:New 'Frame' {
        AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(.5, .5),

        Size = UDim2.fromScale(.65, .65),
        Visible = props.Selected
      }
    }
  }
end

function SkillTreeTab (
  scope: Fusion.Scope<typeof(Fusion)>,

  props: {
    currentSkillTree: any,
    shown: Fusion.UsedAs<boolean>
  }
)
  local innerScope = scope:innerScope {
    SideText = SideText,
    TextBorder = TextBorder
  }


  return scope:New 'ImageLabel' {
    Name = script.Name,
    Visible = props.shown,
    
    Image = 'rbxassetid://18183009519',
    AnchorPoint = Vector2.new(0, 1),
    Size = UDim2.fromScale(.4, .17),
    Position = UDim2.fromScale(.1, .185),
    BackgroundTransparency = 1,
    ImageRectSize = Vector2.new(400, 400),


    [Fusion.Children] = {
      scope:New 'UIGradient' {
        Color = ColorSequence.new({
          ColorSequenceKeypoint.new(0, Color3.fromHex('#0b0c0e')),
          ColorSequenceKeypoint.new(.15, Color3.fromHex('#0b0c0e')),
          ColorSequenceKeypoint.new(.5, Color3.fromHex("#272f41")),
          ColorSequenceKeypoint.new(.85, Color3.fromHex('#0b0c0e')),
          ColorSequenceKeypoint.new(1, Color3.fromHex('#0b0c0e'))
        })
      },

      scope:New 'UISizeConstraint' {
        MinSize = Vector2.new(200, 100),
        MaxSize = Vector2.new(270, math.huge)
      },

      
      scope:New 'TextLabel' {
        Text = 'SKILL TREE',
        FontFace = Font.fromName 'Balthazar',
        AnchorPoint = Vector2.new(.5, 0),

        Position = UDim2.fromScale(.5, .38),
        Size = UDim2.fromScale(.45, .12),

        TextColor3 = Color3.fromHex '#ffffff',
        BackgroundTransparency = 1,
        TextScaled = true
      },


      innerScope:SideText({
        Text = 'Q',
        AnchorPoint = Vector2.new(0, .5),
        Position = UDim2.fromScale(.1, .5)
      }),

      innerScope:TextBorder({
        AnchorPoint = Vector2.new(0, .5),
        Position = UDim2.fromScale(.2, .48)
      }),

      innerScope:TextBorder({
        AnchorPoint = Vector2.new(1, .5),
        Position = UDim2.fromScale(.8, .48)
      }),

      innerScope:SideText({
        Text = 'E',
        AnchorPoint = Vector2.new(1, .5),
        Position = UDim2.fromScale(.9, .5)
      })
    }
  }
end


return SkillTreeTab
