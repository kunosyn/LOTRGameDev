local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local Players = game:GetService('Players')

local Knit = require(ReplicatedStorage.Packages.Knit)
local ProfileService = require(ServerScriptService.Packages.ProfileService)
local PlayerDataSchema = require(ServerScriptService.Source.PlayerDataSchema)


local PlayerDataService = Knit.CreateService({
    Name = 'PlayerDataService',

    Client = { },
    PlayerData = { },
    ProfileStore = nil
})

function PlayerDataService:KnitInit()
    self.ProfileStore = ProfileService.GetProfileStore(
        'PlayerData',
        PlayerDataSchema
    )
end

function PlayerDataService:KnitStart()
    for _,player in Players:GetPlayers() do
        self:OnPlayerJoin(player)
    end

    Players.PlayerAdded:Connect(function(player: Player)
        self:OnPlayerJoin(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player: Player)
        self:OnPlayerLeave(player)
    end)
end


function PlayerDataService:OnPlayerJoin(player: Player)

end

function PlayerDataService:OnPlayerLeave(player: Player)
end

function PlayerDataService:OnProfileLoaded(player: Player, profile: typeof(PlayerDataSchema))
    print(`Loaded profile for {player.Name}.`)
end

function PlayerDataService:ChangePlayerData(player: Player, attribute: string, value: any)
end

return PlayerDataService