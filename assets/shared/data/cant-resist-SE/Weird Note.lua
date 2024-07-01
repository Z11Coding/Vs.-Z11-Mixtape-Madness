--(Note from Z11: ONLY AJUST THE NOTEMULTIPLIER AND AJUST IT BY 0.01'S OR ELSE THE NOTE WILL GO FLYING)
local noteMultiplier = 1.01 -- Initial scroll speed multiplier 
local strumThreshold = 0.3 -- Adjust this value to control the proximity threshold for the slowdown effect

function onUpdatePost()
    for i = 0, getProperty('notes.length') - 1 do
	if getPropertyFromGroup('notes', i, 'noteType') == 'Weird Note' then

        local noteY = getPropertyFromGroup('notes', i, 'multSpeed')
        setPropertyFromGroup('notes', i, 'multSpeed', -noteY)
        --debugPrint(noteY / noteMultiplier)
        --* noteMultiplier * slowdownFactor
        end
    end
end