local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage.Packages.Knit)

local WeaponConfiguration = require(ReplicatedStorage.Source.Configurations.Weapons)


local WeaponService = Knit.CreateService({
    Name = 'WeaponService',

    Client = {
        Killfeed = Knit.CreateUnreliableSignal()
    }
})

function WeaponService:KnitInit()
end


function WeaponService:KnitStart()

end

function WeaponService:DamageSanityChecks(character: Model, target: Model, origin: Tool): boolean
    if (not target or not target.Parent) or (not character or not character.Parent) then
        return false
    end

    if origin:IsA('Tool') and origin:HasTag('Weapon') then
        local weaponProperties = WeaponConfiguration[origin.Name]

        return origin.Parent == character and ((target.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude <= weaponProperties.MaxRange)
    else
        return false
    end
end

function WeaponService:DamagePlayer(player: Player, target: Player, origin: Tool)
    local targetCharacter = target.Character
    local character = player.Character

    if not self:DamageSanityChecks(character, targetCharacter, origin) then
        return
    end

    local humanoid: Humanoid = character:FindFirstChildOfClass('Humanoid')
    if humanoid.Health <= 0 then return end

    local weaponProperties = WeaponConfiguration[origin.Name]
    humanoid:TakeDamage(weaponProperties.Damage)

    if humanoid.health <= 0 then
        self.Client.Killfeed:FireAll(player, target, origin)
    end
end

function WeaponService.Client:RequestPlayerDamage(target: Player, weapon: Tool)
    local character = Knit.Player.Character
    if not character then return end

    self.Server:DamagePlayer(Knit.Player, target, weapon)
end

return WeaponService