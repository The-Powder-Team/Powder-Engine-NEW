package;

import haxe.Exception;
import lime.app.Application;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
import Controls.KeyboardScheme;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

class LoadReplayState extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	var songs:Array<FreeplayState.FreeplaySongMetadata> = [];

	var controlsStrings:Array<String> = [];
	var actualNames:Array<String> = [];

	private var grpControls:FlxTypedGroup<Alphabet>;
	var versionShit:FlxText;
	var poggerDetails:FlxText;

	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage('menuDesat'));
		// TODO: Refactor this to use OpenFlAssets.
		#if FEATURE_FILESYSTEM
		controlsStrings = sys.FileSystem.readDirectory(Sys.getCwd() + "/assets/replays/");
		#end
		trace(controlsStrings);

		controlsStrings.sort(sortByDate);

		addWeek(['Bopeebo', 'Fresh', 'Dadbattle'], 1, ['dad']);
		addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky']);
		addWeek(['Pico', 'Philly', 'Blammed'], 3, ['pico']);

		addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom']);
		addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas']);

		addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai-angry', 'spirit']);

		for (i in 0...controlsStrings.length)
		{
			var string:String = controlsStrings[i];
			actualNames[i] = string;
			var rep:Replay = Replay.LoadReplay(string);
			controlsStrings[i] = string.split("time")[0] + " " + CoolUtil.difficultyFromInt(rep.replay.songDiff).toUpperCase();
		}

		if (controlsStrings.length == 0)
			controlsStrings.push("No Replays...");

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = FlxG.save.data.antialiasing;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...controlsStrings.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, controlsStrings[i], true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		versionShit = new FlxText(5, FlxG.height - 34, 0,
			"Replay Loader (ESCAPE TO GO BACK)\nNOTICE!!!! Replays are in a beta stage, and they are probably not 100% correct. expect misses and other stuff that isn't there!\n",
			12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		poggerDetails = new FlxText(5, 34, 0, "Replay Details - \nnone", 12);
		poggerDetails.scrollFactor.set();
		poggerDetails.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(poggerDetails);

		changeSelection(0);

		super.create();
	}

	function sortByDate(a:String, b:String)
	{
		var aTime = Std.parseFloat(a.split("time")[1]) / 1000;
		var bTime = Std.parseFloat(b.split("time")[1]) / 1000;

		return Std.int(bTime - aTime); // Newest first
	}

	public function getWeekNumbFromSong(songName:String):Int
	{
		var week:Int = 0;
		for (i in 0...songs.length)
		{
			var pog:FreeplayState.FreeplaySongMetadata = songs[i];
			if (pog.songName == songName)
				week = pog.week;
		}
		return week;
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new FreeplayState.FreeplaySongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
			FlxG.switchState(new OptionsMenu());
		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);

		if (controls.ACCEPT && grpControls.members[curSelected].text != "No Replays...")
		{
			trace('loading ' + actualNames[curSelected]);
			PlayState.rep = Replay.LoadReplay(actualNames[curSelected]);

			PlayState.loadRep = true;

			if (PlayState.rep.replay.replayGameVer == Replay.version)
			{
				// adjusting the song name to be compatible
				var songFormat = StringTools.replace(PlayState.rep.replay.songName, " ", "-");
				switch (songFormat)
				{
					case 'Dad-Battle':
						songFormat = 'dadbattle';
					case 'Philly-Nice':
						songFormat = 'philly';
					case 'M.I.L.F':
						songFormat = 'milf';
					// Replay v1.0 support
					case 'dad-battle':
						songFormat = 'dadbattle';
					case 'philly-nice':
						songFormat = 'philly';
					case 'm.i.l.f':
						songFormat = 'milf';
				}

				var songPath = "";

				#if FEATURE_STEPMANIA
				if (PlayState.rep.replay.sm)
					if (!FileSystem.exists(StringTools.replace(PlayState.rep.replay.chartPath, "converted.json", "")))
					{
						Application.current.window.alert("The SM file in this replay does not exist!", "SM Replays");
						return;
					}
				#end

				PlayState.isSM = PlayState.rep.replay.sm;
				#if FEATURE_STEPMANIA
				if (PlayState.isSM)
					PlayState.pathToSm = StringTools.replace(PlayState.rep.replay.chartPath, "converted.json", "");
				#end

				#if FEATURE_STEPMANIA
				if (PlayState.isSM)
				{
					songPath = File.getContent(PlayState.rep.replay.chartPath);
					try
					{
						PlayState.sm = SMFile.loadFile(PlayState.pathToSm + "/" + StringTools.replace(PlayState.rep.replay.songName, " ", "_") + ".sm");
					}
					catch (e:Exception)
					{
						Application.current.window.alert("Make sure that the SM file is called "
							+ PlayState.pathToSm
							+ "/"
							+ StringTools.replace(PlayState.rep.replay.songName, " ", "_")
							+ ".sm!\nAs I couldn't read it.",
							"SM Replays");
						return;
					}
				}
				#end

				try
				{
					if (PlayState.isSM)
					{
						PlayState.SONG = Song.loadFromJsonRAW(songPath);
					}
					else
					{
						var diff:String = ["-easy", "", "-hard"][PlayState.rep.replay.songDiff];
						PlayState.SONG = Song.loadFromJson(PlayState.rep.replay.songName, diff);
					}
				}
				catch (e:Exception)
				{
					Application.current.window.alert("Failed to load the song! Does the JSON exist?", "Replays");
					return;
				}
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = PlayState.rep.replay.songDiff;
				PlayState.storyWeek = getWeekNumbFromSong(PlayState.rep.replay.songName);
				LoadingState.loadAndSwitchState(new PlayState());
			}
			else
			{
				PlayState.rep = null;
				PlayState.loadRep = false;
			}
		}
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		var rep:Replay = Replay.LoadReplay(actualNames[curSelected]);

		poggerDetails.text = "Replay Details - \nDate Created: "
			+ rep.replay.timestamp
			+ "\nSong: "
			+ rep.replay.songName
			+ "\nReplay Version: "
			+ rep.replay.replayGameVer
			+ ' ('
			+ (rep.replay.replayGameVer != Replay.version ? "OUTDATED not useable!" : "Latest")
			+ ')\n';

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
