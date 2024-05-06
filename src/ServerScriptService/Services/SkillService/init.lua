local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local Knit = require(ReplicatedStorage.Packages.Knit)
local SkillProperties = require(script.SkillProperties)

type PlayerData = typeof(require(ServerScriptService.Source.PlayerDataSchema))

type Skill = {
    SkillGroup: number,
    SkillId: number,
    Execute: (skill: Skill, player: Player, character: Model, humanoid: Humanoid) -> nil
}

local PlayerDataService = nil

local SkillService = Knit.CreateService({
    Name = 'SkillService',
    Client = { },
    PlayerData = { }
})

function SkillService:KnitStart()
    PlayerDataService = Knit.GetService('PlayerDataService')

    for _,player in Players:GetPlayers() do
        task.spawn(function()
            self:PlayerAdded(player)
        end)
    end

    Players.PlayerAdded:Connect(function(player: Player)
        self:PlayerAdded(player)
    end)
end

function SkillService:AddSkillPoints(player: Player, amount: number): nil
    local playerData: PlayerData = PlayerDataService:ChangePlayerData(player, 'SkillPoints', amount)

    print(`[SkillService]: Changed {player.Name}\'s SkillPoints to {playerData.SkillPoints}.`)
end

function SkillService:PlayerAdded(player: Player): nil
    local playerData: PlayerData = PlayerDataService:GetPlayerData(player)

    self.PlayerData[player] = {
        Stored = playerData,
        Skills = { }
    }

    for skillGroupNumber,skillGroupSkills in self.PlayerData[player].Stored.Profile.Data.UnlockedSkills do
        local skillSet = skillGroupSkills

        for _,currentSkill in SkillProperties[tonumber(skillGroupNumber)] do
            local hasSkill: boolean = not (not table.find(skillSet, currentSkill.Id))
            if not hasSkill then continue end

            for _,cancelledSkillId in (currentSkill.Overrides or { }) do
                self.PlayerData[player].Skills[cancelledSkillId] = nil
            end

            self.PlayerData[player].Skills[`{skillGroupNumber}:{currentSkill.Id}`] = currentSkill
        end
    end

    player.CharacterAdded:Connect(function (character: Model)
        for _,v in self.PlayerData[player].Skills do
            if v.ModifyProperties then
                v.ModifyProperties(player, character, character:FindFirstChildOfClass('Humanoid'))
            end
        end
    end)
end

function SkillService:PlayerRemoving(player: Player)
    self.PlayerData[player] = nil
end

function SkillService.Client:GetPlayerSkills(player: Player)
    repeat task.wait() until self.Server.PlayerData[player] and self.Server.PlayerData[player].Stored ~= nil

    return self.Server.PlayerData[player].Skills
end

function SkillService.Client:GetSkillPoints(player: Player, skillGroup: number?)
    repeat task.wait() until self.Server.PlayerData[player] and self.PlayerData[player].Stored ~= nil

    return if not skillGroup then self.Server.PlayerData[player].Data.SkillTreeExp else (self.Server.PlayerData[player].Data.SkillTreeExp[skillGroup] or 0)
end

return SkillService