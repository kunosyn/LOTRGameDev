local ReplicatedStorage = game:GetService('ReplicatedStorage')
Knit = require(ReplicatedStorage.Packages.Knit)


local SkillTreeService = Knit.CreateService({
    Name = 'SkillTreeService',
    Client = { }
})


function SkillTreeService:AddSkillPoints()

end


function SkillTreeService.Client:GetSkillPoints()

end

function SkillTreeService.Client:RequestSkillTreePointsIncrease(amount: number)

end


return SkillTreeService