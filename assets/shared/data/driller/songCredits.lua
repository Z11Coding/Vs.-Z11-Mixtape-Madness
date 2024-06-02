local songTable = {
    

    --Tutorial
    -- :(

    --Wiik 1
    --song,         composer,   charter,    og song composer
    {"Light It Up", "ImPaper", "ScottFlux", "TheOnlyVolume", 6620},
    {"Ruckus", "Singular and Lord Voiid", "Ushear", "TheOnlyVolume", 8170},
    {"Target Practice", "Lord Voiid", "ScottFlux", "TheOnlyVolume"},
    
    --Wiik 2
    {"Burnout", "Lord Voiid", "ScottFlux", ""},
    {"Sporting", "Invalid", "Ushear", "Biddle3"},
    {"Boxing Match", "Lord Voiid", "Official_YS", "TheOnlyVolume", 11330},

    --Matt With Hair
    {"Flaming Glove", "ImPaper", "ScottFlux", ""},

    --Wiik 3
    {"Fisticuffs", "Lord Voiid", "RhysRJJ and Lord Voiid", "HamillUn"},
    {"Blastout", "Revilo", "ScottFlux", ""},
    {"Immortal", "Hippo0824 and Lord Voiid", "RhysRJJ", ""},
    {"King Hit", "Lord Voiid", "ScottFlux and RhysRJJ", "TheOnlyVolume"},
    --{"King Hit Wawa", "Lord Voiid", "Official_YS", "TheOnlyVolume"},
    {"TKO", "Lord Voiid and Invalid", "ScottFlux", "HamillUn and Shteque"},

    --Wiik 100
    {"Mat", "Joa (Inst) and Hippo0824 (Voices)", "ScottFlux", "st4rcannon"},
    {"Banger", "Lord Voiid", "bruvDiego", "st4rcannon"},
    {"Edgy", "Lord Voiid (Voices) and MLOM (Inst)", "RhysRJJ", "st4rcannon", 18460},

    --Extras
    {"Sport Swinging", "Ushear", "ScottFlux", "Biddle3"},
    {"Boxing Gladiators", "Ushear", "RhysRJJ", "TheOnlyVolume"},
    {"Rejected", "Lord Voiid", "Official_YS", "CrazyCake", 11320},
    {"Alter Ego", "Lord Voiid and Revilo", "ScottFlux", ""},
    {"Average Voiid Song", "Fallnnn", "Ushear", ""},  
    {"Driller", "Z11Gaming", "Z11Gaming", ""}  
}
local song = {"Song Not Found", "", "", ""}
function onCreatePost()
    for i = 1,#songTable do
        if string.lower(songName) == string.lower(songTable[i][1]) then
            song = songTable[i]
            --trace(song)
        end
    end

    local songFont = "dumbnerd.ttf"
    setProperty('boyfriend.animationNotes',{})
    makeLuaSprite('songBG', 'songPopupThingy',0,screenHeight/2 - 100)
    setObjectCamera('songBG', 'hud')
    
    makeLuaText("songText",song[1],1280, 0,screenHeight/2 - 80)
    setTextFont("songText", songFont)
    setScrollFactor(0,0,'songText')
    setProperty('songText.antialiasing',true)
    setObjectCamera('songText', 'hud')
    setTextSize('songText',100)
    --setProperty('songText.y',getProperty("songText.y")-15)
    local textShit = "Composer: "..song[2].."      Charter: "..song[3]
    if song[4] ~= "" then
        textShit = textShit.."      Original Song: "..song[4]
    end
    --trace(textShit)
    local textSize = 24
    makeLuaText("extraText", textShit, 1280,0, screenHeight/2 - 20)
    setTextFont("extraText", "Contb___.ttf")
    setProperty('extraText.antialiasing',true)
    setScrollFactor(0,0,'extraText')
    setObjectCamera('extraText', 'hud')
    --actorScreenCenter('extraText')
    setProperty('extraText.y',getProperty("extraText.y")+60)
    setTextBorder('extraText', 2,'FFFFFFF')
    setTextBorder('songText', 2,'FFFFFFF')
    setTextSize('extraText',textSize)

    --setActorTextColor("songText", "0xFF6A17EB")
    --setActorTextColor("extraText", "0xFF6A17EB")
    setTextColor("songText", "0xFF000000")
    setTextColor("extraText", "0xFF000000")

    setProperty('songBG.x',getProperty("songBG.x")+2000)
    setProperty('songText.x',getProperty("songText.x")+2000)
    setProperty('extraText.x',getProperty("extraText.x")+2000)
    addLuaSprite('songBG',true)
    addLuaText('extraText',true)
    addLuaText('songText',true)
end
local showedPopups = false
function onSongStart()
    if song[5] == nil then
        showedPopups = true
        movePop(stepCrochet*0.001*8)
    end
end
function movePop(time)
    doTweenX('songBGX',"songBG", getProperty("songBG.x")-2000, time, 'expoOut')
    doTweenX("songTextX","songText", getProperty("songText.x")-2000, time, 'expoOut')
    doTweenX("extraTextX","extraText", getProperty("extraText.x")-2000, time, 'expoOut')
end
local hiddenPopups = false
local killedPopups = false
function onStepHit()
    local delay = 0
    if song[5] ~= nil then  --delay timer thingy
        delay = song[5]
        if songPos > song[5] and not showedPopups then
            showedPopups = true
            movePop(stepCrochet*0.001*8)
        end
    end
    if getSongPosition() > 5000+delay and not hiddenPopups then
        hiddenPopups = true
        movePop(stepCrochet*0.001*7)
    elseif getSongPosition() > 10000+delay and hiddenPopups and not killedPopups then
        killedPopups = true
        removeLuaSprite("songBG",true)
        removeLuaText("songText",true)
        removeLuaText("extraText",true)
    end
end