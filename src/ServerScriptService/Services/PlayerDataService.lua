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
        task.spawn(function() 
            self:OnPlayerJoin(player) 
        end)
    end)
    
    Players.PlayerRemoving:Connect(function(player: Player)
        self:OnPlayerLeave(player)
    end)
end


function PlayerDataService:OnPlayerJoin(player: Player)
    local profile = self.ProfileStore:LoadProfileAsync(`Player_{player.UserId}`)

    if profile then
        profile:AddUserId(player.UserId)
        profile:Reconcile()


        profile:ListenToRelease(function()
            self.PlayerData[player] = nil
            player:Kick('ProfileDataService - PlayerData Profile released.')
        end)


        if player:IsDescendantOf(Players) then
            self.PlayerData[player] = profile
            self:OnProfileLoaded(player, profile)
        else
            profile:Release()
        end
    else
        player:Kick('PlayerDataService - An issue occured loading your data. If this persist please report this bug.')
    end
end

function PlayerDataService:OnPlayerLeave(player: Player)
    local profile = self.PlayerData[player]

    if profile then
        profile:Release()
    end
end

function PlayerDataService:OnProfileLoaded(player: Player, profile: typeof(PlayerDataSchema))
    print(`[PlayerDataService]: Loaded profile for {player.Name}.`)
end

function PlayerDataService:ChangePlayerData(player: Player, attribute: string, value: any)
    self.PlayerData[player].Data[attribute] = value

    return self.PlayerData[player].Data
end

function PlayerDataService:GetPlayerData(player: Player)
    return self.PlayerData[player].Data
end

return PlayerDataService