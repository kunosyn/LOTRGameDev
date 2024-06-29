--!strict
--!nolint LocalShadow

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local StarterGui = game:GetService('StarterGui')

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Components = script.Components


local scope = Fusion.scoped(Fusion, {
  SkillTree = require(Components.SkillTree),
  AdminUi = require(Components.AdminUI)
})


local GuiController = {
  Name = 'GuiController',
  PlayerGui = nil,
  ScreenGui = nil,

  AdminUI = {
    Player = nil,
    ConfirmingBan = nil
  },

  SkillUI = {
    SkillTreeDisplayed = nil
  }
}


function GuiController:UpdateValues ()
end

function GuiController:SetCoreGuiEnabled (enabled: boolean)
  StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, enabled)
end

function GuiController:SetupStates ()
  self.AdminUI.Player = scope:Value(Players:FindFirstChild('kunobypl'))
  self.AdminUI.ConfirmingBan = scope:Value(false)

  self.SkillUI.SkillTreeDisplayed = scope:Value(false)
end

function GuiController:KnitStart ()
  local PlayerGui: PlayerGui = Knit.Player:WaitForChild('PlayerGui', 2)
  assert(PlayerGui, '[GuiController]: PlayerGui returned nil.')

  self:SetupStates()
  --self:SetCoreGuiEnabled(false)

  local ScreenGui: Instance = scope:New 'ScreenGui' {
    Name = 'HUD',
    Parent = PlayerGui,

    IgnoreGuiInset = true,
    ResetOnSpawn = false,

    [Fusion.Children] = {
      scope:AdminUi({
        player = self.AdminUI.Player,
        confirmingBan = self.AdminUI.ConfirmingBan
      })
    }
  }

  self.PlayerGui = PlayerGui
  self.ScreenGui = ScreenGui
end

return GuiController
