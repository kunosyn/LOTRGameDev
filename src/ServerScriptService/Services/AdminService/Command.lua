
local Players = game:GetService('Players')
local TextChatService = game:GetService('TextChatService')

local Commands = TextChatService:FindFirstChild('Commands') or Instance.new('Folder')
Commands.Parent = TextChatService
Commands.Name = 'Commands'


type Implementation = {
    __index: Implementation,
    new: ( name: string ) -> Command,
    Callback: ( self: Command, player: Player, args: { string }) -> nil
}

type Prototype = {
    CommandInstance: TextChatCommand,
    Permissions: table,
    Name: string
}

local Command: Implementation = { }
Command.__index = Command

export type Command = typeof(setmetatable({ } :: Prototype, { } :: Implementation))

function Command.new(name: string, AdminService, Builder: { CommandPrimaryAlias: string?, CommandSecondaryAlias: string?, Parent: Instance?, AutoComplete: boolean?, AutoCompleteIfHasPermissions: boolean? }): Command
    local self = setmetatable({ } :: Prototype, Command)

    self.Name = name

    self.CommandInstance = Instance.new('TextChatCommand')
    self.CommandInstance.Parent = if Builder then Builder.Parent or Commands else Commands

    self.CommandInstance.PrimaryAlias = if Builder and Builder.CommandPrimaryAlias then Builder.CommandPrimaryAlias else `/{name}`
    self.CommandInstance.SecondaryAlias = if Builder and Builder.CommandSecondaryAlias then Builder.CommandSecondaryAlias else ''

    self.CommandInstance.AutocompleteVisible = if Builder and Builder.AutoComplete then true else false

    if Builder and Builder.AutoCompleteIfHasPermissions then
        for _,player in Players:GetPlayers() do
            if not self:CheckPermissions(player) then continue end

            AdminService:ExecuteClientLogic(player, 'CommandAutoComplete', {
                AutoComplete = true, CommandInstance = self.CommandInstance
            })
        end
    end

    self.CommandInstance.Triggered:Connect(function(originTextSource: TextSource, unfilteredText: string)
        local player = Players:FindFirstChild(originTextSource.Name)
        if not player then return end

        local args = unfilteredText:split(' ')
        table.remove(args, 1)

        local result: boolean = self:Execute(player, args)

        if result.Exception then
            AdminService:CommandFailed(player, result.Message)
        elseif result.Success then
            AdminService:SendClientMessage(player, 'Command successfully executed.')
        end
    end)

    return self
end

function Command:CheckPermissions(player: Player): boolean
    if self.Permissions.Any then return true end

    for groupId, ranks in self.Permissions do
        if player:IsInGroup(groupId) then
            for _, rankId in ranks do
                if player:GetRankInGroup(groupId) == rankId then
                    return true
                end
            end
        end
    end

    return false
end

function Command:Execute(player: Player, args: { string }): boolean
    if not self:CheckPermissions(player) then return end
    return self:Callback(player, args)
end

return Command