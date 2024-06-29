local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local Knit = require(ReplicatedStorage.Packages.Knit)
local Loader = require(ReplicatedStorage.Packages.Loader)


local controllers = Loader.LoadChildren(script.Parent.Services, Loader.MatchesName('Service$'))
for _,controller in controllers do
    Knit.CreateService(controller)
end

Knit.Start():andThen(function()
    print('Knit Server Started.')
end):catch(warn)
