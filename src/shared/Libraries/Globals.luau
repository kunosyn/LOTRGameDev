--!strict
--!nolint LocalShadow

local Players = game:GetService('Players')

local Duration = require(script.Parent.Parent.Configurations.Duration)
local Globals = { }


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

function Globals:GetIso8601String (): string
  local function pad(number)
    return string.format('%02d', number)
  end

  local currentTime = os.date('*t')

  return string.format(
    '%d-%s-%sT%s:%s:%s.000Z',
    currentTime.year,
    pad(currentTime.month),
    pad(currentTime.day),
    pad(currentTime.hour),
    pad(currentTime.min),
    pad(currentTime.sec)
  )
end

function Globals:GetTimeInSecondsFromString (duration: string): (number, string)
  local numberArgument = tonumber(duration:match('^%d+'))
  if not numberArgument then return 0, '' end

  local suffixArgument = duration:match('%a+$')
  if not suffixArgument then return 0, '' end

  suffixArgument = suffixArgument:lower()
  local suffix = if numberArgument > 1 then `{Duration.DurationNames[suffixArgument]}s` else Duration.DurationNames[suffixArgument]

  local durationString = `{numberArgument} {suffix}`

  return Duration.DurationSuffixes[suffixArgument] * numberArgument, durationString
end

return Globals
