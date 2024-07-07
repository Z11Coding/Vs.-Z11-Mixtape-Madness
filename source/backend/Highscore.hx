package backend;

class Highscore
{
	public static var weekScores:Map<String, Int> = new Map();
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songRating:Map<String, Float> = new Map<String, Float>();
	public static var songMisses:Map<String, Int> = new Map<String, Int>();
	public static var songRanks:Map<String, Int> = new Map<String, Int>();
	public static var songDeaths:Map<String, Int> = new Map<String, Int>();

	public static function resetSong(song:String, diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		setScore(daSong, 0);
		setRating(daSong, 0);
		setMisses(daSong, 0);
	}

	public static function resetWeek(week:String, diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);
		setWeekScore(daWeek, 0);
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if(decimals < 1)
		{
			return Math.floor(value);
		}

		var tempMult:Float = 1;
		for (i in 0...decimals)
		{
			tempMult *= 10;
		}
		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}

	public static function saveRank(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if (songRanks.exists(daSong))
		{
			if (songRanks.get(daSong) > score)
				setRank(daSong, score);
		}
		else
			setRank(daSong, score);
	}

	public static function saveDeaths(song:String, deaths:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		setDeaths(daSong, deaths);
	}

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0, ?rating:Float = -1, ?misses:Int = 0):Void
	{
		//Score and Rating now save seperately and Misses now save as well.
		var daSong:String = formatSong(song, diff);

		if (songScores.exists(daSong)) {
			if (songScores.get(daSong) < score) {
				setScore(daSong, score);
			}
		}
		else {
			setScore(daSong, score);
		}
		if (songRating.exists(daSong)) {
			if (songRating.get(daSong) < rating) {
				setRating(daSong, rating);
			}
		}
		else {
			if(rating >= 0) setRating(daSong, rating);
		}
		if (songMisses.exists(daSong)) {
			if (songMisses.get(daSong) > misses) {
				setMisses(daSong, misses);
			}
		}
		else {
			if(misses >= 0) setMisses(daSong, misses);
		}
	}

	public static function saveWeekScore(week:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);

		if (weekScores.exists(daWeek))
		{
			if (weekScores.get(daWeek) < score)
				setWeekScore(daWeek, score);
		}
		else
			setWeekScore(daWeek, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setRank(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songRanks.set(song, score);
		FlxG.save.data.songRanks = songRanks;
		FlxG.save.flush();
	}
	static function setDeaths(song:String, deaths:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		var deathCounter:Int = songDeaths.get(song) + deaths;

		songDeaths.set(song, deathCounter);
		FlxG.save.data.songDeaths = songDeaths;
		FlxG.save.flush();
	}
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}
	static function setWeekScore(week:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		weekScores.set(week, score);
		FlxG.save.data.weekScores = weekScores;
		FlxG.save.flush();
	}

	static function setRating(song:String, rating:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songRating.set(song, rating);
		FlxG.save.data.songRating = songRating;
		FlxG.save.flush();
	}

	static function setMisses(song:String, misses:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songMisses.set(song, misses);
		FlxG.save.data.songMisses = songMisses;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		return Paths.formatToSongPath(song) + Difficulty.getFilePath(diff);
	}

	public static function getScore(song:String, diff:Int):Int
	{
		var daSong:String = formatSong(song, diff);
		if (!songScores.exists(daSong))
			setScore(daSong, 0);

		return songScores.get(daSong);
	}
	public static function getRank(song:String, diff:Int):Int
	{
		if (!songRanks.exists(formatSong(song, diff)))
			setRank(formatSong(song, diff), 16);

		return songRanks.get(formatSong(song, diff));
	}
	public static function getDeaths(song:String, diff:Int):Int
	{
		if (!songDeaths.exists(formatSong(song, diff)))
			setDeaths(formatSong(song, diff), 0);

		return songDeaths.get(formatSong(song, diff));
	}
	public static function getRating(song:String, diff:Int):Float
	{
		var daSong:String = formatSong(song, diff);
		if (!songRating.exists(daSong))
			setRating(daSong, 0);

		return songRating.get(daSong);
	}

	public static function getMisses(song:String, diff:Int):Int
	{
		var daSong:String = formatSong(song, diff);
		if (!songMisses.exists(daSong))
			setMisses(daSong, 0);	

		return songMisses.get(daSong);
	}

	public static function getWeekScore(week:String, diff:Int):Int
	{
		var daWeek:String = formatSong(week, diff);
		if (!weekScores.exists(daWeek))
			setWeekScore(daWeek, 0);

		return weekScores.get(daWeek);
	}

	public static function load():Void
	{
		if (FlxG.save.data.weekScores != null)
		{
			weekScores = FlxG.save.data.weekScores;
		}
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
		if (FlxG.save.data.songRating != null)
		{
			songRating = FlxG.save.data.songRating;
		}
		if (FlxG.save.data.songMisses != null)
		{
			songMisses = FlxG.save.data.songMisses;
		}
		if (FlxG.save.data.songRanks != null)
		{
			songRanks = FlxG.save.data.songRanks;
		}
		if (FlxG.save.data.songDeaths != null)
		{
			songDeaths = FlxG.save.data.songDeaths;
		}
	}
}