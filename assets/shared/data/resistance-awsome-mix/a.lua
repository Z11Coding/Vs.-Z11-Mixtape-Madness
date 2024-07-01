function onCreatePost()
    setProperty('gf.x', getProperty('gf.x')-1300)
    setProperty('gf.y', getProperty('gf.y')-100)
end

function onStepHit()
    if curStep == 1263 then
        doTweenX("z11", "gf", 400, 1, "sineOut")
    end
    if curStep == 2048 then
        doTweenY("z11", "gf", -2000, 12, "sineOut")
        doTweenAngle("z11a", "gf", 360, 6, "sineOut")
        doTweenAlpha("z11al", "gf", 0, 2, "sineOut")
    end
end