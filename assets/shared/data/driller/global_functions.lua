function makeNoteCopy(name,id,data)
    local noteTexture = getPropertyFromGroup('notes',id,'texture')
    if noteTexture == '' or noteTexture == nil then
        noteTexture = 'NOTE_assets'
    end
    if getPropertyFromGroup('notes',id,'visible') then
            --makeAnimatedLuaSprite(name,noteTexture,getPropertyFromGroup('strumLineNotes',data,'x'),getPropertyFromGroup('strumLineNotes',data,'y'))
        makeAnimatedLuaSprite(name,noteTexture,getPropertyFromGroup('notes',id,'x'),getPropertyFromGroup('notes',id,'y'))
        local anim = getPropertyFromGroup('notes',id,'animation.frameName')
        addAnimationByPrefix(name,getPropertyFromGroup('notes',id,'animation.curAnim.name'),string.sub(anim,0,string.len(anim) - 3),getPropertyFromGroup('notes',id,'animation.curAnim.frameRate'),getPropertyFromGroup('notes',id,'animation.curAnim.looped'))
        setObjectCamera(name,'hud')
        scaleObject(name,getPropertyFromGroup('notes',id,'scale.x'),getPropertyFromGroup('notes',id,'scale.y'))
        setProperty(name..'.offset.x',getPropertyFromGroup('notes',id,'offset.x'))
        setProperty(name..'.offset.y',getPropertyFromGroup('notes',id,'offset.y'))
        setProperty(name..'.angle',getPropertyFromGroup('notes',id,'angle'))
        setProperty(name..'.alpha',getPropertyFromGroup('notes',id,'alpha'))
        addLuaSprite(name,true)
    end
end
function makeSpriteCopy(tag,sprite,directory,isAnimated)
    local character = false
    if sprite == 'boyfriend' or sprite == 'gf' or sprite == 'dad' then
        character = true
        if directory == nil then
            directory = getProperty(sprite..'.imageFile')
        end
    end
    if isAnimated then
        makeAnimatedLuaSprite(tag,directory,getProperty(sprite..'.x'),getProperty(sprite..'.y'))
        local anim = getProperty(sprite..'.animation.frameName')
        addAnimationByPrefix(tag,'anim',string.sub(anim,0,#anim - 3),getProperty(sprite..'.animation.curAnim.frameRate'),getProperty(sprite..'.animation.curAnim.looped'))
    else
        makeLuaSprite(tag,directory,getProperty(sprite..'.x'),getProperty(sprite..'.y'))
    end
    --setObjectCamera(tag,'hud')

    setProperty(tag..'.angle',getProperty(sprite..'.angle'))
    setProperty(tag..'.alpha',getProperty(sprite..'.alpha'))
    scaleObject(tag,getProperty(sprite..'.scale.x'),getProperty(sprite..'.scale.y'))
    addLuaSprite(tag,false)
    if not character then
        setObjectOrder(tag,getObjectOrder(sprite))
        --scaleObject(tag,getProperty(sprite..'.scale.x'),getProperty(sprite..'.scale.y'))
    else
        setObjectOrder(tag,getObjectOrder(sprite..'Group'))
        --scaleObject(tag,getProperty(sprite..'.scale.x') + (getProperty(sprite..'.jsonScale') - 1),getProperty(sprite..'.scale.y') + (getProperty(sprite..'.jsonScale') - 1))
    end
    setProperty(tag..'.offset.x',getProperty(sprite..'.offset.x'))
    setProperty(tag..'.offset.y',getProperty(sprite..'.offset.y'))
end
function playerDodge(random,data)
    local bfCharacter = getProperty('boyfriend.curCharacter')
    local bfAnims = {
        'Wiik3BFRTX',
        'Wiik3BFSingRTX',
        'TKOBFOnii',
        'Wiik3BFOnii',
        'Wiik2BFRTX',
        'Wiik100BF'
    }

    for bfs = 1,#bfAnims do
        if bfCharacter == bfAnims[bfs] then
            local dodges = {'LEFT','DOWN','UP','RIGHT'}
            if random ~= false then
                playAnim('boyfriend','dodge'..dodges[math.random(1,#dodges)],true)
            else
                playAnim('boyfriend','dodge'..dodges[data + 1],true)
            end
            setProperty('boyfriend.specialAnim',true)
            return
        end
    end
    if bfCharacter == 'bfBOX' then
        if getRandomBool() then
            playAnim('boyfriend','dodge',true)
        else
            playAnim('boyfriend','duck',true)
        end
        setProperty('boyfriend.specialAnim',true)
    end
end
function updateStage()
    setProperty('stageLuas',getStageLuas(true))
end
function onCreate()
    runHaxeCode(
        [[
            setVar('stageLuas',null);
        ]]
    )
end
function onCreatePost()
    updateStage()
end
function getStageLuas(stages)
    local stageFiles = runHaxeCode(
        [[
            var luaSprites = [];
            for(k in game.modchartSprites.keys()){
                if(game.getLuaObject(k).cameras[0] == game.camGame && game.getLuaObject(k).wasAdded){
                    luaSprites.push(k);
                }
            }
            return luaSprites;
        ]]
    )
    if stages ~= false and #stageFiles > 0 then
        local copyStage = {}
        local notStage = {
            'mattShield',
            'bfShield',
            'auraMatt',
        }
        local stringFind = {
            'MattStand',
            'Echo',
            'rainGraphic'
        }
        for i,luaN in ipairs(stageFiles) do
            for dont = 1,#notStage do
                if luaN == notStage[dont] then
                    goto next
                end
            end
            for find = 1,#stringFind do
                if string.match(luaN,stringFind[find]) ~= nil then
                    goto next
                end
            end
            table.insert(copyStage,luaN)
            ::next::
        end
        stageFiles = copyStage
    end
    return stageFiles
end
function setStageColorSwap(var,value,tween,time,easing)
    local spriteCreated = getStageLuas()
    --table.insert(spriteCreated,'boyfriend')
    --table.insert(spriteCreated,'dad')
    --table.insert(spriteCreated,'gf')
    for i,stages in pairs(spriteCreated) do
        if not tween then
            setProperty(stages..'.'..var,value)
        else
            if var == 'color' then
                doTweenColor(stages..'Color',stages,value,time,easing)
            end
        end
    end
end
function showOnlyStrums(show)
    if not hideHud then
        setProperty('healthBar.visible',not show)
        setProperty('scoreTxt.visible',not show)

        setProperty('healthBarVoiid.visible',not show)
        setProperty('iconP1.visible',not show)
        setProperty('iconP2.visible',not show)
        --setProperty('healthBarBG.visible',not show)
    end
    if timeBarType ~= 'Disabled' then
        --setProperty('timeTxt.visible',not show)
        --setProperty('timeBar.visible',not show)
        setProperty('timeBarBGVoiid.visible',not show)
        setProperty('timeTxtVoiid.visible',not show)
        setProperty('timeBarBG.visible',not show)
    end
end