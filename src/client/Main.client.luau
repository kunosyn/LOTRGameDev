--!strict
--!nolint LocalShadow

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local Knit = require(ReplicatedStorage.Packages.Knit)
local Globals = require(ReplicatedStorage.Source.Globals)


Knit.AddControllers(script.Parent.Controllers)

Knit:Start():andThen(function()
    print('Knit Client started.')
end)
