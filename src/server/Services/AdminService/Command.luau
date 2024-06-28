--!strict
--!nolint LocalShadow

local Players = game:GetService('Players')
local TextChatService = game:GetService('TextChatService')

local Commands = TextChatService:FindFirstChild('Commands') or Instance.new('Folder')
Commands.Parent = TextChatService
Commands.Name = 'Commands'


type Implementation = {
    __index: Implementation,

    new: ( name: string, AdminService: any, Builder: {
        CommandPrimaryAlias: string?,
        CommandSecondaryAlias: string?,
        Parent: Instance?,
        AutoComplete: boolean?,
        AutoCompleteIfHasPermissions: boolean?,

    } ) -> Command,

    Callback: ( self: Command, player: Player)  -> CommandExecutionStatus,
    CheckPermissions: ( self: Command, player: Player, ...any ) -> boolean,
    Execute: ( self: Command, player: Player, ...any ) -> CommandExecutionStatus,

    Error: ( message: string, error: string? ) -> CommandExecutionStatus,
    Success: ( ) -> CommandExecutionStatus,
    Log: ( self: Command, executor: Player, target: Player?, reason: string? ) -> ()
}

type Prototype = {
    CommandInstance: TextChatCommand,
    Permissions: { [number]: {number}, Any: boolean? },
    Name: string,
    AutoCompleteIfHasPermissions: boolean,
    AdminService: any
}

export type CommandExecutionStatus = {
    IsSuccess: boolean,
    Message: string?,
    Error: string?
}


local Command: Implementation = { } :: Implementation
Command.__index = Command

export type Command = typeof(setmetatable({ } :: Prototype, { } :: Implementation))

function Command.new (name: string, AdminService, Builder: {
    CommandPrimaryAlias: string?,
    CommandSecondaryAlias: string?,
    Parent: Instance?,
    AutoComplete: boolean?,
    AutoCompleteIfHasPermissions: boolean?
}): Command
    local self = setmetatable({} :: Prototype, Command)
    Builder = if Builder then Builder else {}

    self.Name = name
    self.AdminService = AdminService


    self.CommandInstance = Instance.new('TextChatCommand')
    self.CommandInstance.Parent = if Builder then Builder.Parent or Commands else Commands

    self.CommandInstance.PrimaryAlias = if Builder.CommandPrimaryAlias then Builder.CommandPrimaryAlias else `/{name}`
    self.CommandInstance.SecondaryAlias = if Builder.CommandSecondaryAlias then Builder.CommandSecondaryAlias else ''

    self.CommandInstance.AutocompleteVisible = not (not Builder.AutoComplete)
    self.AutoCompleteIfHasPermissions =  not (not Builder.AutoCompleteIfHasPermissions)

    self.CommandInstance.Triggered:Connect(function (originTextSource: TextSource, unfilteredText: string)
        local player = Players:FindFirstChild(originTextSource.Name)
        if not player then
            return
        end

        local args = unfilteredText:split(' ')
        table.remove(args, 1)

        local result: CommandExecutionStatus = self:Execute(player, unpack(args))


        if not result.IsSuccess then
            AdminService:TriggerCommandFailed(player, result.Message, result.Error)
        else
            AdminService:SendClientMessage(player, 'Command successfully executed.')
        end
    end)

    return self
end

function Command.Error (message: string, error: string?): CommandExecutionStatus
    return { IsSuccess = false, Message = message, Error = error }
end

function Command.Success (): CommandExecutionStatus
    return { IsSuccess = true }
end

function Command:Log (executor: Player, target: Player?, reason: string?)
    self.AdminService:LogCommand(executor, self.Name, target, reason)
end

function Command:CheckPermissions (player: Player): boolean
    if self.Permissions.Any then return true end

    for groupId, ranks in self.Permissions do
        if typeof(groupId) ~= 'number' then continue end
       
        if not player:IsInGroup(groupId) then
            continue
        end

        for _, rankId in ranks do
            if player:GetRankInGroup(groupId) == rankId then
                return true
            end
        end
    end

    return false
end

function Command:Execute (player: Player, ...): CommandExecutionStatus
    if not self:CheckPermissions(player) then
        return Command.Error('Invalid permissions to run command.')
    end

    return self:Callback(player, ...)
end

return Command
