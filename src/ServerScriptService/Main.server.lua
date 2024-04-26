local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

Knit = require(ReplicatedStorage.Packages.Knit)


Knit.AddServices(ServerScriptService.Services)

Knit.Start():andThen(function()
    print('Knit Server Started.')
end):catch(warn)