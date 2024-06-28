--!strict
--!nolint LocalShadow

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local Knit = require(ReplicatedStorage.Packages.Knit)
local SkillProperties = require(script.SkillProperties)
local Services = ServerScriptService.Source.Services

type PlayerData = typeof(require(Services.PlayerDataService.PlayerDataSchema))

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

-- function SkillService:AddSkillPoints(player: Player, skillTree: number, amount: number)
--     local playerData: PlayerData = PlayerDataService:ChangePlayerData(player, 'SkillPoints', amount)

--     print(`[SkillService]: Changed {player.Name}\'s SkillTreeExp to {playerData.SkillTreeExp[skillTree]}.`)
-- end

function SkillService:PlayerAdded(player: Player)
    local playerData: PlayerData = PlayerDataService:GetPlayerData(player)

    self.PlayerData[player] = {
        Stored = playerData,
        Skills = { }
    }

    for skillGroupNumber,skillGroupSkills in self.PlayerData[player].Stored.Profile.Data.UnlockedSkills do
        local skillSet = skillGroupSkills

        for _, currentSkill in SkillProperties[tonumber(skillGroupNumber)] do
            local hasSkill: boolean = not (not table.find(skillSet, currentSkill.Id))
            if not hasSkill then continue end

            for _,cancelledSkillId in (currentSkill.Overrides or { }) do
                self.PlayerData[player].Skills[cancelledSkillId] = nil
            end

            self.PlayerData[player].Skills[`{skillGroupNumber}:{currentSkill.Id}`] = currentSkill
        end
    end

    local function characterAdded(character: Model)
        for _, currentSkill in self.PlayerData[player].Skills do
            if currentSkill.ModifyProperties then
                currentSkill.ModifyProperties(player, character, character:FindFirstChildOfClass('Humanoid'))
            end
        end
    end

    player.CharacterAdded:Connect(characterAdded)

    characterAdded(
        if not player.Character or not player.Character.Parent then
            player.CharacterAdded:Wait()
        else
            player.Character
    )
end

function SkillService:PlayerRemoving(player: Player)
    self.PlayerData[player] = nil
end

function SkillService.Client:GetPlayerSkills(player: Player): { any }
    -- Resolving the current player's skills from server.
    repeat
        task.wait()
    until self.Server.PlayerData[player] and self.Server.PlayerData[player].Stored

    -- Returning the current player's skills.
    return self.Server.PlayerData[player].Skills
end

function SkillService.Client:GetSkillPoints(player: Player, skillGroup: number?): { any } | number
    -- Resolving the current player's skill points from the server.
    repeat
        task.wait()
    until self.Server.PlayerData[player] and self.PlayerData[player].Stored

    return if not skillGroup then
        -- Returning complete skill tree if skill group does not exist.
        self.Server.PlayerData[player].Data.SkillTreeExp
    else
        -- Returning skill group if exists.
        self.Server.PlayerData[player].Data.SkillTreeExp[skillGroup] or 0
end

return SkillService
