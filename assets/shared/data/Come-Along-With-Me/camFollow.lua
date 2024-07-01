---@funkinScript

local stuff = {
  disabled = false,
  anims = {
    ['singleft'] = {-60, 'x'},
    ['singdown'] = {60, 'y'},
    ['singup'] = {-60, 'y'},
    ['singright'] = {60, 'x'},
    ['singleft-loop'] = {-60, 'x'},
    ['singdown-loop'] = {60, 'y'},
    ['singup-loop'] = {-60, 'y'},
    ['singright-loop'] = {60, 'x'},
  },
  check = {
    [true] = 'boyfriend',
    [false] = 'dad',
  },
}

function getDecimalPlaces(decimal)
  local decimalString = tostring(decimal);
  local _, decimalPart = decimalString:match('(%d+)%.(%d+)');
  local decimalPlaces = decimalPart and #decimalPart or 0
  return decimalPlaces > 0 and tonumber('0.'..string.rep('0', decimalPlaces)..'1') or 0.1
end

function lerp(currentValue, targetValue, lerpSpeed, elapsedSpeed, thresholdDivAmount)
  local currentValue = tonumber(currentValue) or 1
  local targetValue = tonumber(targetValue) or currentValue + 1
  local lerpSpeed = tonumber(lerpSpeed) or 2
  local elapsedSpeed = tonumber(elapsedSpeed) or lerpSpeed
  local thresholdDivAmount = tonumber(thresholdDivAmount) or 20
  local difference = targetValue - currentValue
  local speed = lerpSpeed * elapsedSpeed
  local amount = difference * speed
  currentValue = currentValue + amount
  amount = math.min(amount, difference);
  local threshold = getDecimalPlaces(targetValue) / thresholdDivAmount
  if math.abs(difference) < threshold then currentValue = targetValue end
  return currentValue
end

function onUpdatePost(elapsed)
  if stuff.disabled then return end
  local character = stuff.check[mustHitSection]
  local name = getProperty(character..'.animation.curAnim.name'):lower();
  local anim_info = stuff.anims[name]
  if anim_info then
    local offset = anim_info[1]
    local axis = anim_info[2]
    local follow = (version:find('0.7') and 'camGame.scroll' or 'camFollowPos')..'.'
    local var = follow..axis
    local currentPos = getProperty(var);
    local newPos = lerp(currentPos, currentPos + offset, 1 * getProperty('cameraSpeed') * playbackRate, elapsed, 1);
    setProperty(var, newPos);
  end
end