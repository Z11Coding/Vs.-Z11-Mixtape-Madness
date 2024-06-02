function onStepHit()
    if boyfriendName == 'bf-super' then
        if curStep % 32 == 0 then
            playSound('spark', 0.3)
            --space for visual sparks on bf
        end
    end
end

function onEvent(name, v1, v2)
    if name == 'Change Character' then
        --[[
        if boyfriendName == 'bf' and v2 == 'bf-super' then
            playSound('power_up', 0.5)
        elseif boyfriendName == 'bf-super' and v2 == 'bf' then
            playSound('power_down', 0.5)
        end
        --]]

        if v2 == 'bf-super' then
            playSound('dbc_power_up', 2)
            cameraShake('game', 0.05, 1)
            cameraShake('hud', 0.03, 1)
        elseif v2 == 'bf' then
            playSound('dbc_power_down', 2)
        end
    end
end
