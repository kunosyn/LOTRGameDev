local ContextActionService = game:GetService('ContextActionService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage.Packages.Knit)

local Skills = require(script.Skills)

local SkillService = nil

local SkillsController = {
    Name = 'SkillsController',
    SkillsTable = { },
    OnSpawnFunctions = { }
}

function SkillsController:KnitStart ()
    SkillService = Knit.GetService('SkillService')

    SkillService:GetPlayerSkills():andThen(function(skills)
        self.SkillsTable = skills

        for _,skill in self.SkillsTable do
            if skill.KeyCode then
                ContextActionService:BindAction(skill.Name, Skills[skill.CallbackId], false, skill.KeyCode)
            end

            if skill.ModifyProperties then
                table.insert(self.OnSpawnFunctions, skill.ModifyProperties)
            end
        end
    end):catch(warn)
end


return SkillsController
