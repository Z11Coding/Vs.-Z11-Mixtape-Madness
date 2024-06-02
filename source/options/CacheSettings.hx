package options;

class CacheSettings extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Cache Settings.';
		rpcTitle = 'Cache Settings'; // for Discord Rich Presence

		var option:Option = new Option('Cache Graphics', // even tho only one person asked, it here
			"If checked, The Graphics Will Be Cached.", 'graphicsPreload2', 'bool');
		addOption(option);

		var option:Option = new Option('Cache Music', // even tho only one person asked, it here
			"If checked, The Music Will Be Cached.", 'musicPreload2', 'bool');
		addOption(option); // now shut up before i put you in my basement

		super();
	}
}
