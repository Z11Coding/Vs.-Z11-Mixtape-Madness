gameOver = false
plank = true

function onGameOver()
    if not plank then
        restartSong()
    end
    gameOver = true
    return Function_Stop;
end

function onUpdate()
    if gameOver and plank then
        setProperty('vocals.volume', 1)
        setProperty('playbackRate', getProperty('playbackRate')-0.0075)
    end
    if plank then
        if playbackRate < 0 then
            restartSong(true)
        end
    end
end