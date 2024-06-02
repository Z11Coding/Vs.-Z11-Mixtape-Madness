function onEvent(name, value1, value2)
    if name == 'middlescroll' then
        if value1 == '1' then
            if not middlescroll then
                for i = 0,3 do
                    noteTweenX('noteMiddleX'..i,i,(420 + (112 * i)),1,'linear') --middlescroll for opponent
                    setPropertyFromGroup('strumLineNotes',i,'alpha',0.3)
                end
                for i = 4,7 do
                    noteTweenX('noteMiddleX'..i,i,(420 + (112 * (i - 4))),1,'linear')
                end
            end
        elseif value2 == '2' then --psych midscroll on
            if not middlescroll then
                for i = 0,3 do
                    if i < 2 then
                        noteTweenX('noteMiddleX'..i,i,(80 + (112 * i)),1,'linear')
                    else
                        noteTweenX('noteMiddleX'..i,i,(972 + (112 * (i - 2))),1,'linear')
                    end
                end
            end
        elseif value2 == '3' then --psych midscroll off
            if not middlescroll then
                for i = 0,3 do
                    noteTweenX('noteMiddleX'..i,i,(420 + (112 * i)),1,'linear')
                end
            end
        elseif value2 == '4' then --tween to default
            if not middlescroll then
                for i = 0,7 do
                    tweenPosOut(i,_G['defaultStrum'..i..'X'],_G['defaultStrum'..i..'Y'],1)
                    setPropertyFromGroup('strumLineNotes',i,'alpha',1)
                end
            end
        end
    end
end