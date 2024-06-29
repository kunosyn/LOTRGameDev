--!strict
--!nolint LocalShadow

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local Knit = require(ReplicatedStorage.Packages.Knit)
local Loader = require(ReplicatedStorage.Packages.Loader)
local Globals = require(ReplicatedStorage.Source.Globals)


local controllers = Loader.LoadChildren(script.Parent.Controllers, Loader.MatchesName('Controller$'))
for _,controller in controllers do
    Knit.CreateController(controller)
end


Knit:Start():andThen(function()
    print('Knit Client started.')
end)
