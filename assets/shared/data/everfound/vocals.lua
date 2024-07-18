function onUpdate()
    if difficultyName == 'Gin' then
        runHaxeCode([[
            game.vocals.volume = 0;
        ]])
        setSoundTime("altVoices", getProperty("vocals.time"))
    end
end

function onUpdatePost()
    if difficultyName == 'Gin' then
        runHaxeCode([[
            game.vocals.volume = 0;
        ]])
        setSoundTime("altVoices", getProperty("vocals.time"))
    end
end

function goodNoteHit()
    if difficultyName == 'Gin' then
        setSoundVolume("altVoices", 1)
        runHaxeCode([[
            game.vocals.volume = 0;
        ]])
    end
end

function opponentNoteHit()
    if difficultyName == 'Gin' then
        setSoundVolume("altVoices", 1)
        runHaxeCode([[
            game.vocals.volume = 0;
        ]])
    end
end

function onPause()
    if difficultyName == 'Gin' then
        pauseSound("altVoices")
        runHaxeCode([[
            game.vocals.volume = 0;
        ]])
    end
end

function onResume()
    if difficultyName == 'Gin' then
        resumeSound("altVoices")
        runHaxeCode([[
            game.vocals.volume = 0;
        ]])
    end
end

function onNoteMiss()
    if difficultyName == 'Gin' then
        setSoundVolume("altVoices", 0)
    end
end

function onCreatePost()
    if difficultyName == 'Gin' then
        runHaxeCode([[
            game.vocals.volume = 0;
        ]])
        precacheSound("Voices-alt")
    end
end

function onSongStart()
    if difficultyName == 'Gin' then
        runHaxeCode([[
            game.vocals.volume = 0;
        ]])
        playSound("Voices-alt", 1, "altVoices")
    end
end