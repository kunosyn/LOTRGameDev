local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerDataService = nil

local AdminService = Knit.CreateService({
    Name = 'AdminService',
    Config = require(script.AdminConfig),

    Client = {
        SendChatMessage = Knit.CreateSignal(),
        ClientLogicRequest = Knit.CreateSignal()
    }
})

function AdminService:KnitStart(): nil
    PlayerDataService = Knit.GetService('PlayerDataService')

    for _,command in script.Commands:GetChildren() do
        require(command)(AdminService) -- Builds Command
    end
end

function AdminService:SendClientMessage(player: Player?, message: string): nil
    if player then
        self.Client.SendChatMessage:Fire(player, message)
    else
        self.Client.SendChatMessage:FireAll(message)
    end
end

function AdminService:ExecuteClientLogic(player: Player?, request: string, args: table): nil
    if player then
        self.Client.ClientLogicRequest:Fire(player, request, args)
    else
        self.Client.ClientLogicRequest:FireAll(request, args)
    end
end

function AdminService:PermBan(player: Player): nil
    PlayerDataService:ChangePlayerData(player, 'IsBanned', true)
    self:SendClientMessage(nil, `{player.Name} has been permanently banned.`)
end

function AdminService:ProfileLoaded(player: Player, profile): nil
    if profile.Data.IsBanned then
        player:Kick(self.Config.BanMessage)
    end

    local chatTags: table = { self.Config.ChatTags.Users[player.UserId] }

    for groupId,tags in self.Config.ChatTags.Groups do
        if player:IsInGroup(groupId) then
            for _,tag in tags do
                if tag.RankRange then
                    local rankRange = tag.RankRange:split(':')
                    local playerRank = player:GetRankInGroup(groupId)

                    if playerRank >= tonumber(rankRange[1]) and playerRank <= tonumber(rankRange[2]) then
                        table.insert(chatTags, tag)
                    end
                elseif tag.RankIds then
                    if table.find(tag.RankIds, player:GetRankInGroup(groupId)) then
                        table.insert(chatTags, tag)
                    end
                end
            end
        end
    end

    self:ExecuteClientLogic(nil, 'ChatTagsAdd', { player, chatTags})

    local nameRedaction = self.Config.RedactedNames.Users[player.UserId]

    if nameRedaction then
        nameRedaction = nameRedaction.RedactMessage
        self:ExecuteClientLogic(nil, 'NameRedaction', { player, nameRedaction })
    else
        for groupId,redactionData in self.Configs.RedactedNames.Groups do
            if player:IsInGroup(groupId) then
                if redactionData.RankRange then
                    local rankRange = redactionData.RankRange:split(':')
                    local playerRank = player:GetRankInGroup(groupId)

                    if playerRank >= tonumber(rankRange[1]) and playerRank <= tonumber(rankRange[2]) then
                        nameRedaction = redactionData.RedactMessage
                        break
                    end
                elseif redactionData.RankIds then
                    if table.find(redactionData.RankIds, player:GetRankInGroup(groupId)) then
                        nameRedaction = redactionData.RedactMessage
                        break
                    end
                end
            end
        end
    end
end

function AdminService:CommandFailed(player: Player, message: string): nil
    self:SendClientMessage(player, `Command failed to execute: {message}`)
end

return AdminService