--function onBeatHit()
--for i = 1,2 do
--scaleObject('iconP1',1,1)
--doTweenX('tagx1','iconP1.scale',1.1,0.3)
--doTweenY('tagy1','iconP1.scale',1.1,0.3)
--scaleObject('iconP2',1,1)
--doTweenX('tagx2','iconP2.scale',1.1,0.3)
--doTweenY('tagy2','iconP2.scale',1.1,0.3)
--end
--end

function opponentNoteHit(i,d,t,s)
if d or s then
scaleObject('iconP2',1,1)
doTweenX('tagx2','iconP2.scale',1.1,0.1)
doTweenY('tagy2','iconP2.scale',1.1,0.1)
end
end


function goodNoteHit(i,d,t,s)
if d or s then
scaleObject('iconP1',1,1)
doTweenX('tagx1','iconP1.scale',1.1,0.1)
doTweenY('tagy1','iconP1.scale',1.1,0.1)
end
end