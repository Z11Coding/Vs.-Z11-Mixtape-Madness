function onEvent(name, value1, value2)
    if name == 'Clear Popups' then
        for i = 1, 100 do 
            objectPlayAnimation('error_popups'..i, 'end') 
            runTimer('enddd', .1)
        end
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'enddd' then
        for i = 1, 100 do 
            setProperty('error_popups'..i..'.visible', false);
        end
    end
end