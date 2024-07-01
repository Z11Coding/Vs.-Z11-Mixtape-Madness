function onEvent(n)
    if n == 'Add Camera Zoom' then
        cameraShake('camGame', 0.01, 0.05)
        cameraShake('camHUD', 0.01, 0.05)
    end
end