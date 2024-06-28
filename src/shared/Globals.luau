--!strict
--!nolint LocalShadow

local Globals = { }

local Players = game:GetService('Players')

function Globals:GetPlayerFromPartialName (partial: string): Player?
  if #partial == 0 then return nil end
  local returnedPlayer: Player? = nil

  for _,player in Players:GetChildren() do
    if player.Name:sub(0, #partial) ~= partial then
      continue
    end

    returnedPlayer = player
  end

  return returnedPlayer
end


return Globals
