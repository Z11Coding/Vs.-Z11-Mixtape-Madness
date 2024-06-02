function onCreate()
	-- background shit
	makeLuaSprite('theSky', 'black', -50, 50);
	addLuaSprite('theSky',true)
        setProperty('theSky.visible',true);	

        makeLuaSprite('theSky2', 'bg', 350, 50);
	addLuaSprite('theSky2',false)
        setProperty('theSky2.visible',false);

        makeLuaSprite('theGround' , 'ground' ,-50,550)
	addLuaSprite('theGround',false)
        setProperty('theGround.visible',false);

        makeLuaSprite('theHalfPipe' , 'blanco' ,-350,100)
	addLuaSprite('theHalfPipe',false)
        setProperty('theHalfPipe.visible',false);

        makeLuaSprite('theHalfPipe2' , 'blanco' ,350,550)
	addLuaSprite('theHalfPipe2',false)
        setProperty('theHalfPipe2.visible',false);
	close(true);
end