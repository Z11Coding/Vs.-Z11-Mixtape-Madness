local precacheWarnings = true; -- If warnings will be printed when a file might be or was unable to be precached
function precacheAsset(asset,type)
    sprite = sprite:match('%s?[^,)]+');
    if((sprite:match('..') or sprite:match('%(.-%)')) and precacheWarnings) then
        debugPrint(string.format('Warning: %q looks like it might contain variables or functions, it might not precache correctly!',sprite))
    end
    sprite = sprite:match("[^'\"]+")
    local succ,err = pcall(function()
        (getfenv and getfenv() or _ENV or _G)['precache' .. type](sprite)
    end)
    if(precacheWarnings and not succ) then
        debugPrint(string.format('Error: %q was unable to be precached: %s',sprite,err))
    end
end
function precacheLuaScript(script)
    local luaFile = checkFileExists(script..'.lua') and getTextFromFile(script..'.lua') or getTextFromFile(script)
    for sprite in luaFile:gmatch('makeLuaSprite%((.-)%)[%s;]') do
        precacheAsset(sprite:match(',(.+)'),'Image')
    end
    for sound in luaFile:gmatch('playSound%((.-)%)[%s;]') do
        precacheAsset(sound,'Sound')
    end
    for music in luaFile:gmatch('playMusic%((.-)%)[%s;]') do
        precacheAsset(music,'Music')
    end
end
-- Script made by Gavman22/Vyxia#8393
-- Modified by Superpowers04#3887
function onCreatePost()
    for i = 0,getProperty('eventNotes.length')-1 do
        if getPropertyFromGroup('eventNotes', i, 'event') == 'Change The Stage' then
            local value1 = tostring(getPropertyFromGroup('eventNotes', i, 'value1'))
            value1 = stringSplit(value1, ',')
            local newStageName = tostring(value1[1])
            precacheLuaScript('stages/'..newStageName)
        end
    end
end