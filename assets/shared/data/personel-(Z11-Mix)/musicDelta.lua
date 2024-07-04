local prevTime = 0;

function onCreate()
	--luaDebugMode = true
end

function onUpdatePost() -- I SWEAR TO GOD please don't change this to onUpdate() :(
	--debugPrint(getPropertyFromClass('flixel.FlxG', 'elapsed'))
	setPropertyFromClass('flixel.FlxG', 'elapsed', math.min(math.max((getPropertyFromClass('flixel.FlxG', 'sound.music.time') - prevTime) / 60, 1 / 60), 0.02))
	prevTime = getPropertyFromClass('flixel.FlxG', 'sound.music.time')
end