--!strict
--!nolint LocalShadow

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')
local HttpService = game:GetService('HttpService')

local Environment = require(ServerStorage.Source.Environment)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Globals = require(ReplicatedStorage.Source.Globals)

local PlayerDataService = nil


local AdminService = {
    Name = 'AdminService',
    Config = require(script.AdminConfig),

    Client = {
        SendChatMessage = Knit.CreateSignal(),
        ClientLogicRequest = Knit.CreateSignal()
    },

    Commands = { },
    CommandLogs = { }
}

function AdminService:KnitStart ()
    PlayerDataService = Knit.GetService('PlayerDataService')

    for _,command in script.Commands:GetChildren() do
        local builder = require(command) :: ( AdminService: typeof(AdminService) ) -> ()

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


function AdminService:RegisterCommand(command)
    table.insert(self.Commands, command)
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

function AdminService:LogCommand (executor: Player, commandName: string, target: Player? | number?, reason: string?, duration: string?)
    local headshot: string?
    local success,err = pcall(function()
        local response = HttpService:GetAsync(`https://thumbnails.roproxy.com/v1/users/avatar-headshot?userIds={executor.UserId}&size=720x720&format=Png&isCircular=false`)
        response = HttpService:JSONDecode(response).data[1]

        headshot = response.imageUrl
    end)

    local targetName: string?, targetId: number?
    if target then
        targetName = if typeof(target) == 'number' then Players:GetNameFromUserIdAsync(target) else target.Name
        targetId = if typeof(target) == 'number' then target else target.UserId
    end

    success,err = pcall(function()
        local body = {
            embeds = {
                {
                    color = 12490697,

                    author = {
                        name = `{executor.Name} ({executor.UserId})`,
                        url = `https://www.roblox.com/users/{executor.UserId}/profile`,
                        icon_url = if success then headshot else ''
                    },
                    
                    fields = {
                        {
                            name = 'Command',
                            value = commandName,
                            inline = true
                        },

                        {
                            name = 'Executed On',
                            value = if target then `[{targetName}](https://www.roblox.com/users/{targetId}/profile)` else 'Server',
                            inline = true
                        },

                        {
                            name = 'Timestamp',
                            value = `\`<t:{os.time()}:F>\``,
                            inline = true
                        } 
                    },

                    footer = {
                        text = 'Made by kunosyn',
                        icon_url = 'https://kunosyn.com/icon.png?a53b4d639e148403'
                    },

                    timestamp = Globals:GetIso8601String()
                }
            },

            username = executor.Name,
            avatar_url = 'https://kunosyn.com/icon.png?a53b4d639e148403'
        }


        if duration then
            table.insert(body.embeds[1].fields, {
                name = 'Duration',
                value = duration,
                inline = true
            })
        end

        if reason and not reason:match('^%s*$') then
            table.insert(body.embeds[1].fields, {
                name = if commandName == 'announce' then 'Message' else 'Reason',
                value = reason,
                inline = true
            })
        end

        HttpService:PostAsync(Environment.WEBHOOK_URL, HttpService:JSONEncode(body))
    end)

    if success then
        print('[AdminService]: Successfully logged command to webhook.')
    else
        print('[AdminService]: Failed to log command to webhook.')
        warn(err)
    end
end

function AdminService:ProfileLoaded (player: Player, profile)
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
