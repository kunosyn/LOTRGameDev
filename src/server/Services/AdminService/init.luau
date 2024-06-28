--!strict
--!nolint LocalShadow

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerDataService = nil

local AdminService = Knit.CreateService({
    Name = 'AdminService',
    Config = require(script.AdminConfig),

    Client = {
        SendChatMessage = Knit.CreateSignal(),
        ClientLogicRequest = Knit.CreateSignal()
    },

    Commands = { }
})

function AdminService:KnitStart ()
    PlayerDataService = Knit.GetService('PlayerDataService')

    for _,command in script.Commands:GetChildren() do
        local builder = require(command) :: ( AdminService: any ) -> ()

        builder(AdminService)
    end

    for _,player in Players:GetPlayers() do
        task.spawn(function()
            self:ToggleCommandAutoComplete(player)
        end)
    end

end


function AdminService:SendClientMessage (player: Player?, message: string)
    if player then
        self.Client.SendChatMessage:Fire(player, message)
    else
        self.Client.SendChatMessage:FireAll(message)
    end
end


function AdminService:ExecuteClientLogic (player: Player?, request: string, ...)
    if player then
        self.Client.ClientLogicRequest:Fire(player, request, ...)
    else
        self.Client.ClientLogicRequest:FireAll(request, ...)
    end
end


function AdminService:Ban (player: Player, duration: number, reason: string?): (boolean, any)
    local success,err = pcall(function()
        Players:BanAsync({
            UserIds = { player.UserId },
            ApplyToUniverse = true,
            Duration = duration,
            DisplayReason = if duration == -1 then AdminService.Config.BanMessage else 'You have been temporarily banned for breaking the rules.',
            PrivateReason = reason or 'Banned for breaking the rules.',
            ExcludeAltAccounts = false
        })
    end)

    if success then
        self:SendClientMessage(nil, if duration == -1 then `{player.Name} has been permanently banned.` else `{player.Name} has been banned for {duration}s.`)
    end


    return success, err
end

function AdminService:LogCommand (executor: Player, commandName: string, target: Player?, reason: string?)
    
end

function AdminService:ProfileLoaded (player: Player, profile)
    if profile.Data.IsBanned then
        player:Kick(self.Config.BanMessage)
    end

    local chatTags: { string } = { self.Config.ChatTags.Users[player.UserId] }

    for groupId,tags in self.Config.ChatTags.Groups do
        if not player:IsInGroup(groupId) then
            continue
        end

        for _,tag in tags do
            if tag.RankRange then
                local rankRange = tag.RankRange:split(':')
                local playerRank = player:GetRankInGroup(groupId)
                
                local rangeStart, rangeEnd = tonumber(rankRange[1]), tonumber(rankRange[2])
                if not rangeStart or not rangeEnd then continue end

                if playerRank >= rangeStart and playerRank <= rangeEnd then
                    table.insert(chatTags, tag)
                end
            elseif tag.RankIds then
                if table.find(tag.RankIds, player:GetRankInGroup(groupId)) then
                    table.insert(chatTags, tag)
                end
            end
        end
    end

    if #chatTags > 0 then
        self:ExecuteClientLogic(nil, 'ChatTagsAdd', player, chatTags)
    end

    local nameRedaction = self.Config.RedactedNames.Users[player.UserId]

    if nameRedaction then
        nameRedaction = nameRedaction.RedactMessage
        self:ExecuteClientLogic(nil, 'NameRedaction', { player, nameRedaction })
    else
        for groupId,redactionData in self.Configs.RedactedNames.Groups do
            if not player:IsInGroup(groupId) then
                continue
            end


            if redactionData.RankRange then
                local rankRange = redactionData.RankRange:split(':')
                local playerRank = player:GetRankInGroup(groupId)

                local rangeStart, rangeEnd = tonumber(rankRange[1]), tonumber(rankRange[2])
                if not rangeStart or not rangeEnd then continue end

                if playerRank >= rangeStart and playerRank <= rangeEnd then
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

    self:ToggleCommandAutoComplete(player)
end


function AdminService:TriggerCommandFailed (player: Player, message: string, error: string?)
    print('[AdminService]: Command failed to execute.')
    warn(error or message)

    self:SendClientMessage(player, `Command failed to execute: {message}`)
end


function AdminService:ToggleCommandAutoComplete (player: Player)
    local commandsToDisplay = { }

    for _,command in self.Commands do
        if command.AutoCompleteIfHasPermissions and command:CheckPermissions(player) then
            table.insert(commandsToDisplay, command.CommandInstance)
        end
    end

    self:ExecuteClientLogic(player, 'CommandAutoComplete', commandsToDisplay, true)
end


return AdminService
