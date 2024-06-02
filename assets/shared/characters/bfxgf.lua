function onCreate()
	setPropertyFromClass('GameOverSubstate', 'characterName', 'bfxgf'); --Character json file for the death animation
	setPropertyFromClass('GameOverSubstate', 'deathSoundName', '2dead'); --put in mods/sounds/
	setPropertyFromClass('GameOverSubstate', 'loopSoundName', '2deadmusic'); --put in mods/music/
	setPropertyFromClass('GameOverSubstate', 'endSoundName', 'confirm'); --put in mods/music/
end