local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

Knit = require(ReplicatedStorage.Packages.Knit)

type PlayerData = typeof(require(ServerScriptService.Source.PlayerDataSchema))
PlayerDataService = nil


local SkillTreeService = Knit.CreateService({
    Name = 'SkillTreeService',
    Client = { }
})

function SkillTreeService:KnitStart()
    PlayerDataService = Knit.GetService('PlayerDataService')
end

function SkillTreeService:AddSkillPoints(player: Player, amount: number)
    local playerData: PlayerData = PlayerDataService:ChangePlayerData(player, 'SkillPoints', amount)

    print(`[SkillTreeService]: Changed {player.Name}\'s SkillPoints to {playerData.SkillPoints}.`)
end


function SkillTreeService.Client:GetSkillPoints(player: Player)
    local playerData: PlayerData = PlayerDataService:GetPlayerData(player)

    return playerData.SkillPoints
end

return SkillTreeService