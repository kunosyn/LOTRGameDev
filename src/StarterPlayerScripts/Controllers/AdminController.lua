local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterGui = game:GetService('StarterGui')
local TextChatService = game:GetService('TextChatService')

local Knit = require(ReplicatedStorage.Packages.Knit)

local AdminService = nil

local AdminController = Knit.CreateController({
    Name = 'AdminController',
    ChatTags = { },
    RedactedNames = { }
})

function AdminController:KnitStart()
    AdminService = Knit.GetService('AdminService')

    self:ListenForServerRequests()
    self:BindEvents()
end

function AdminController:ListenForServerRequests()
    AdminService.ClientLogicRequest:Connect(function(request: string, args: { string })
        if request == 'Message' then
            local player: Player = args[1]
            local message: string = args[2]

            local icon = nil
            local success,_ = pcall(function()
                icon = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            end)

            StarterGui:SetCore('SendNotification', {
                Title = `{player.DisplayName} (@{player.Name})`,
                Text = message,
                Icon = if success then icon else ''
            })
        elseif request == 'ChatTagsAdd' then
            local player: Player = args[1]
            local chatTags: table = args[2]

            local tagString = ''
            for _,tag in chatTags do
                tagString = `{tagString}<font color='{tag.Color}'>{tag.Value}</font> `
            end

            self.ChatTags[player] = tagString
        elseif request == 'NameRedaction' then
            local player: Player = args[1]
            local redactMessage: string = args[2]

            self.RedactedNames[player] = redactMessage
        elseif request == 'CommandAutoComplete' then
            local commandInstance: { TextChatCommand } | TextChatCommand = args[1]
            local autocomplete: boolean = args[2]

            if typeof(commandInstance) == 'table' then
                for _,command in commandInstance do
                    command.AutocompleteVisible = autocomplete
                end
            else
                commandInstance.AutocompleteVisible = true
            end
        end
    end)

    AdminService.SendChatMessage:Connect(function(message: string)
        local generalChannel: TextChannel = TextChatService.TextChannels.RBXGeneral

        generalChannel:DisplaySystemMessage(message)
    end)
end

function AdminController:BindEvents()
    TextChatService.OnIncomingMessage = function(message: TextChatMessage)
        if not message.TextSource then
            message.Text = `<font color='#57a8ff'>{message.Text}</font>`
            message.PrefixText = `<font color='#ffbe3d'>[SYSTEM]: </font>`
        else
            local player: Player? = Players:FindFirstChild(message.TextSource.Name)

            if player then
                local nameRedaction = self.RedactedNames[player]
                message.PrefixText = if nameRedaction then nameRedaction else message.PrefixText

                local tags = self.ChatTags[player]
                if not tags then return end

                message.PrefixText = `{tags}{message.PrefixText}`
            end
        end
    end
end

return AdminController