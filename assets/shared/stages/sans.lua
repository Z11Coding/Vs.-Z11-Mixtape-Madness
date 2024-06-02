function onCreatePost()
    makeLuaSprite("bg", 'kinemorto/Sans/back', 0, 0)
    screenCenter("bg", 'xy')
    addLuaSprite("bg")

    makeLuaSprite("cliff", 'kinemorto/Sans/cliff', 0, 0)
    screenCenter("cliff", 'xy')
    addLuaSprite("cliff")

    makeLuaSprite("smoke", 'kinemorto/Sans/smoke', 0, 0)
    screenCenter("smoke", 'xy')
    addLuaSprite("smoke")

    makeLuaSprite("front", 'kinemorto/Sans/front', 0, 0)
    screenCenter("front", 'xy')
    addLuaSprite("front")

    makeAnimatedLuaSprite("papshead", 'kinemorto/Sans/paps_head', 400, 500)
    addAnimationByPrefix("papshead", "fade away", "fucking_dies", 24, false)
    addAnimationByPrefix("papshead", "idle", "PAPS_HEAD", 24, false)
    addLuaSprite("papshead")
end

function onBeatHit()
    if getProperty("papshead.animation.curAnim.name") == 'idle' then
        if curBeat % 2 == 0 then
            playAnim('papshead', 'idle', true)
        end
    end
end