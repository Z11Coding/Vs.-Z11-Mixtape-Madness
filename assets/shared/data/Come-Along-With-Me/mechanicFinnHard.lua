missSword = 0
Attack = 0
function onMissSword()
if missSword == 0 then
objectPlayAnimation('healthBarScript', 'win', true);
end

if missSword == 1 then
objectPlayAnimation('healthBarScript', 'normal', true);
end

if missSword == 2 then
objectPlayAnimation('healthBarScript', 'loss', true);
end

if missSword >= 3 then
setProperty('health',0)
end
end

function onUpdate()
if Attack >= 5 then
missSword = missSword - 1 
Attack = Attack - 5 
onMissSword()
end
end

function noteMiss(id,data,type,sus)
if type =='Dodge Note' then
missSword = missSword + 1
onMissSword()
end
end

function goodNoteHit(id,data,type,sus)
if type =='Attack Note' then
Attack = Attack + 1
end
end

function onBeatHit()
if curBeat % 2 == 0 then
onMissSword()
end
end
