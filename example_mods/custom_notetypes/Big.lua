local colors = {"c24b99", "00ffff", "12fa05", "f9393f"}
local prefixes = {"A", "B", "C", "D"}

function onCreatePost()
	for i = 0, getProperty("unspawnNotes.length")-1 do
        if getPropertyFromGroup("unspawnNotes", i, "noteType") == "Big" then
            setPropertyFromGroup("unspawnNotes", i, "color", getColorFromHex(colors[getPropertyFromGroup("unspawnNotes", i, "noteData") + 1]))
        end
    end

    local newSize = 1.5
    local pos = 0

    for i = 1, 4 do
        if i == 1 then
            pos = 1.5
        end
        if i == 2 then
            pos = 0.5
        end
        if i == 3 then
            pos = -0.5
        end
        if i == 4 then
            pos = -1.5
        end

        makeAnimatedLuaSprite("rcpt"..i, "CENTERNOTE_assets")
        addAnimationByIndices("rcpt"..i, "anim", prefixes[i])
        objectPlayAnimation("rcpt"..i, "anim")
        setObjectCamera("rcpt"..i, "hud")
        setProperty("rcpt"..i..".alpha", 0.0001)
        scaleObject("rcpt"..i, newSize, newSize)
        setProperty("rcpt"..i..".x", (screenWidth / 2 - (160 * newSize) / 2) - ((160 * newSize) * pos))
        setProperty("rcpt"..i..".y", screenHeight / 2 - (160 * newSize) / 2)
        addLuaSprite("rcpt"..i, "add")
    end
end

function onUpdatePost(elapsed)
    for i = 0, getProperty("notes.length")-1 do
        if getPropertyFromGroup("notes", i, "noteType") == "Big" then
            local strumTime = getPropertyFromGroup("notes", i, "strumTime")
            local data = getPropertyFromGroup("notes", i, "noteData")
            local time = getPropertyFromClass("Conductor", "songPosition")
            local newSize = 2
            local mod = (time - strumTime) / 1000
            newSize = 1.5 - mod * (getPropertyFromClass("PlayState", "SONG.speed") * -1)
            setPropertyFromGroup("notes", i, "scale.x", newSize)
            setPropertyFromGroup("notes", i, "scale.y", newSize)
            updateHitboxFromGroup("notes", i)
    
            if newSize < 0 then
                setPropertyFromGroup("notes", i, "visible", false)
            else
                setPropertyFromGroup("notes", i, "visible", true)
            end

            setPropertyFromGroup("notes", i, "angle", 0)
            setPropertyFromGroup("notes", i, "alpha", 1)
    
            local pos = 0
            if data == 3 then
                pos = -1.5
            end
            if data == 2 then
                pos = -0.5
            end
            if data == 1 then
                pos = 0.5
            end
            if data == 0 then
                pos = 1.5
            end
            setPropertyFromGroup("notes", i, "x", (screenWidth / 2 - (160 * newSize) / 2) - ((160 * 1.5) * pos))
            setPropertyFromGroup("notes", i, "y", screenHeight / 2 - (160 * newSize) / 2)
        end
    end
end

function goodNoteHit(index, data, datype, sus)
    if datype:lower() == 'big' then
        setProperty("rcpt"..(data + 1)..".angle", 0)
        doTweenAngle("weee"..data, "rcpt"..(data + 1), 360, (60 / getPropertyFromClass("PlayState", "SONG.bpm")) / 2)
        setProperty("camHUD.zoom", getProperty("camHUD.zoom") + 0.1)
        if getProperty("camHUD.zoom") > 1.6 then
            characterPlayAnim("gf", "cheer", true)
        end
    end
end
