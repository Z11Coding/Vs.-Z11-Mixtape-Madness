function onCreate()
	-- background shit
	makeLuaSprite('theSky', 'stages/personel/black', -50, 50);
	addLuaSprite('theSky',true)
        setProperty('theSky.visible',true);	

        makeLuaSprite('theSky2', 'stages/personel/bg', 350, 50);
	addLuaSprite('theSky2',false)
        setProperty('theSky2.visible',false);

        makeLuaSprite('theGround' , 'stages/personel/ground' ,-50,550)
	addLuaSprite('theGround',false)
        setProperty('theGround.visible',false);

        makeLuaSprite('theHalfPipe' , 'stages/personel/blanco' ,-350,100)
	addLuaSprite('theHalfPipe',false)
        setProperty('theHalfPipe.visible',false);

        makeLuaSprite('theHalfPipe2' , 'stages/personel/blanco' ,350,550)
	addLuaSprite('theHalfPipe2',false)
        setProperty('theHalfPipe2.visible',false);
	close(true);
end