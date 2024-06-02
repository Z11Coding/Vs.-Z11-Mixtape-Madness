function onCreatePost()
    addHaxeLibrary("AL", "lime.media.openal")
end

local songPlaying = false
local allowFilter = false

function onSongStart()
    songPlaying = true
    allowFilter = true
end

function onEndSong()
    songPlaying = false
    allowFilter = false
end

function onGameOver()
    songPlaying = false
end

function onPause()
    songPlaying = false
end

function onResume()
    songPlaying = true
end

function onUpdatePost()
    if songPlaying and allowFilter then
        runHaxeCode([[

        var inst = true;
        var vocal = true;

        var af = AL.createFilter(); // create AudioFilter
        AL.filteri(af, 0x8001, 0x0001); // set filter type
        AL.filterf(af, 0x0001, 1); // set gain
        AL.filterf(af, 0x0002, (game.health)); // set gainhf

        if (inst)
            AL.sourcei(FlxG.sound.music._channel.__audioSource.__backend.handle, 0x20005, af); // apply filter to source (handle)
        if (vocal && game.vocals._channel != null)
            AL.sourcei(game.vocals._channel.__audioSource.__backend.handle, 0x20005, af); // apply filter to source (handle)
        ]])
    end
end