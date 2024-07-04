function onCreate()

    makeLuaSprite('sky','stages/leancity/sky', -100, -100)
    addLuaSprite('sky',false)
    --setScrollFactor('sky',0.8, 0.8);

    makeLuaSprite('moon','stages/leancity/moon', 0, -100)
    addLuaSprite('moon',false)

    makeLuaSprite('cloud','stages/leancity/bg_cloud', 0, -50)
    addLuaSprite('cloud',false)

    makeLuaSprite('city', 'stages/leancity/bg_city', -80, 50)
    addLuaSprite('city',false)
    setScrollFactor('city',0.8, 0.8);
    
    makeLuaSprite('thebacktree','stages/leancity/back_tree', -50, -10)
    addLuaSprite('thebacktree',false)
    setScrollFactor('thebacktree',0.8, 0.8);
    
    makeLuaSprite('thefronttree','stages/leancity/front_tree', 0, -10)
    addLuaSprite('thefronttree',false)
    setScrollFactor('thefronttree',0.8, 0.8);

    makeLuaSprite('theAlley','stages/leancity/alley2',0,-100)
    addLuaSprite('theAlley',false)
    --setScrollFactor('theAlley',0.8, 0.8);
    scaleObject('theAlley', 1, 1.2)
    
    makeLuaSprite('thegate','stages/leancity/foreground_gate', 0, 100)
    addLuaSprite('thegate',true)
    --setScrollFactor('thegate',0.8, 0.8);
end 

