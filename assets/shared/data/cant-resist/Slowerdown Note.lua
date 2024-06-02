--(Note from Z11: ONLY AJUST THE NOTEMULTIPLIER AND AJUST IT BY 0.01'S OR ELSE THE NOTE WILL GO FLYING)
local noteMultiplier = 1.02 -- Initial scroll speed multiplier 
local strumThreshold = 0.3 -- Adjust this value to control the proximity threshold for the slowdown effect

function onUpdate()
    for i = 0, getProperty('notes.length') - 1 do
	if getPropertyFromGroup('notes', i, 'noteType') == 'Slowerdown Note' then
        local strumTime = getPropertyFromGroup('notes', i, 'strumTime')
        local distanceToStrum = strumTime - getPropertyFromClass('Conductor', 'songPosition')
        
        -- Calculate slowdown factor based on distance to strum
        local slowdownFactor = math.max(0, distanceToStrum / strumThreshold)

        -- Apply the slowdown factor to the note's scroll speed multiplier
        local noteY = getPropertyFromGroup('notes', i, 'multSpeed')
        setPropertyFromGroup('notes', i, 'multSpeed', noteY / noteMultiplier)
        --debugPrint(noteY / noteMultiplier)
        --* noteMultiplier * slowdownFactor
        end
    end
end