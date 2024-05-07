--[[
    Parameters:
        Required:
            Id [ number ]

        Optionals:
            ModifyProperties: [ func (player: Player, character: Model, humanoid: Humanoid): nil ]
            CallbackId: [ string ]
            KeyCode [Enum.KeyCode ]
            Overrides [ table(number) ]
            RequiredId [ number | table(number) ]
--]]

return {
    [0] = {
        HPBoost10 = {
            Id = 1,
            Name = 'HPBoost10',

            ModifyProperties = function(player: Player, character: Model, humanoid: Humanoid)
                humanoid.MaxHealth += (humanoid.MaxHealth * .1)
                humanoid.Health = humanoid.MaxHealth
            end
        },

        WSBoost5 = {
            Id = 2,
            Name = 'WSBoost5',

            RequiredId = 1,
            ModifyProperties = function(player: Player, character: Model, humanoid: Humanoid)
                humanoid.WalkSpeed += (humanoid.WalkSpeed * .5)
            end
        },

        HPBoost25 = {
            Id = 3,
            Name = 'HPBoost25',

            RequiredId = 2,
            Overrides = { '0:1' },

            ModifyProperties = function(player: Player, character: Model, humanoid: Humanoid)
                humanoid.MaxHealth += (humanoid.MaxHealth * .25)
                humanoid.Health = humanoid.MaxHealth
            end
        },

        StrongArm = {
            Id = 4,
            Name = 'StrongArm',

            RequiredId = 3,
            CallbackId = '0:4',

            KeyCode = Enum.KeyCode.Z
        }
    }
}