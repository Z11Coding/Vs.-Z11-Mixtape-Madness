--scripts by NTH208
function onCreatePost()
    for i =0,3 do
        noteTweenX('NoteX'..i,i,getPropertyFromGroup('strumLineNotes',i,'x')- 50,0.1,'linear')
        noteTweenY('NoteY'..i,i,getPropertyFromGroup('strumLineNotes',i,'y')- 50,0.1,'linear')
    end
    
    for n = 0,getProperty('unspawnNotes.length')-1 do
        if not getPropertyFromGroup('unspawnNotes',n,'mustPress') then
            setPropertyFromGroup('unspawnNotes',n,'offsetX', getPropertyFromGroup('unspawnNotes',n,'offsetX')+ 55)
            setPropertyFromGroup('unspawnNotes',n,'offsetY', getPropertyFromGroup('unspawnNotes',n,'offsetY')+ 50)
        end 
    end 

    for i = 0,3 do
        setPropertyFromGroup('opponentStrums',i,'rgbShader.enabled', false)
        setPropertyFromGroup('opponentStrums',i,'useRGBShader', false)
        setPropertyFromGroup('opponentStrums',i,'texture','opponentNote/Arrows')
    end
end