#if FEATURE_FILESYSTEM
package;

import lime.app.Application;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
import flixel.ui.FlxBar;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.input.keyboard.FlxKey;

using StringTools;

class Caching extends MusicBeatState
{
	var toBeDone = 0;
	var done = 0;

	var loaded = false;

	var text:FlxText;
	var kadeLogo:FlxSprite;

	public static var bitmapData:Map<String, FlxGraphic>;

	var images = [];
	var music = [];
	var charts = [];

	var tips:Array<String> = [
		"Note Skins are available!\nGo follow how the \"Swag\" skin does it!",
		"If you can't see where the rating and the combo counter?\nTick \"Stationary Ratings\" in the Options Menu!\n(you can also change its' positions as well!)\n\n(if you don't see it, it's right below that option i just said)\n(it's called \"Change Rating and Combo positions\")",
		"Never make an FNF engine\nworst mistake of my life",
		"The wait will be worth it",
		"Go pico\nyeah yeah",
		"i'm in disarray",
		"a dice, a diamond, and a skull.\nsomething weird about these, y'know?",
		"my brother in christ\nyou made the sandwich",
		"ah aaaaaah ah eh eh ih ou\nih ou ih ehhh", // liquated
		"nice argument senator, why don't you back it up with a source?\n\n\n\n\n\nmy source is that i made it the fuck up",
		"back in my day big 'ol bunny was the shit\n\n\nokay grandpa let's get you to bed",
		"\"x and y or z\"\nwhat the fuck is this LUA\nshit aint even a native ternary operator\nit is but an imitation" +
		(FlxG.random.bool() ? ", an impostor, perhaps" : "") + "\nlua please",
		"while (true) {}",
		"\"x ? y : z\"\nNOW THAT'S A TERNARY OPERATOR",
		"imma be real this shit does nothing",
		"wah",
		"i wish i could add back \"Space to Hey!\" but i can't :(((((",
		"documentation... sigh",
		"Todokete",
		"child.kill()",
		"https://discord.gg/2vAAKtvMqW join the server"
		"vs allany is fire /j",
		"how come you call vs foxa bad it has some effort put into it",
		"you know i've come to realize something\n\ni love putting something like this\nin my projects"
	];

	override function create()
	{
		FlxG.save.bind('funkin', 'ninjamuffin99');

		PlayerSettings.init();

		PowderEngineData.initSave();

		// It doesn't reupdate the list before u restart rn lmao
		NoteskinHelpers.updateNoteskins();

		FlxG.sound.muteKeys = [FlxKey.fromString(FlxG.save.data.muteBind)];
		FlxG.sound.volumeDownKeys = [FlxKey.fromString(FlxG.save.data.volDownBind)];
		FlxG.sound.volumeUpKeys = [FlxKey.fromString(FlxG.save.data.volUpBind)];

		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0, 0);

		bitmapData = new Map<String, FlxGraphic>();

		text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300, 0, "Loading...");
		text.size = 34;
		text.alignment = FlxTextAlign.CENTER;
		text.alpha = 0;

		kadeLogo = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.loadImage('KadeEngineLogo'));
		kadeLogo.x -= kadeLogo.width / 2;
		kadeLogo.y -= kadeLogo.height / 2 + 100;
		text.y -= kadeLogo.height / 2 - 125;
		text.x -= 170;
		kadeLogo.setGraphicSize(Std.int(kadeLogo.width * 0.6));
		if (FlxG.save.data.antialiasing != null)
			kadeLogo.antialiasing = FlxG.save.data.antialiasing;
		else
			kadeLogo.antialiasing = true;

		kadeLogo.alpha = 0;

		FlxGraphic.defaultPersist = FlxG.save.data.cacheImages;

		#if FEATURE_FILESYSTEM
		if (FlxG.save.data.cacheImages)
		{
			Debug.logTrace("caching images...");

			// TODO: Refactor this to use OpenFlAssets.
			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/noteskins")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push(i);
			}
		}

		Debug.logTrace("caching music...");

		// TODO: Get the song list from OpenFlAssets.
		music = Paths.listSongsToCache();
		#end

		toBeDone = Lambda.count(images) + Lambda.count(music);

		var bar = new FlxBar(10, FlxG.height - 50, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width, 40, null, "done", 0, toBeDone);
		bar.color = FlxColor.PURPLE;

		tip = new FlxText(0, 0, FlxG.width, "", 16);
		tip.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tip.y = bar.y - bar.height + 20;
		tip.scrollFactor.set();
		tip.alpha = 0;
		tip.borderSize = 4;
		add(tip);

		tip.text = tips[FlxG.random.int(0, tips.length - 1)];

		add(bar);

		add(kadeLogo);
		add(text);

		trace('starting caching..');

		#if FEATURE_MULTITHREADING
		// update thread

		sys.thread.Thread.create(() ->
		{
			while (!loaded)
			{
				if (toBeDone != 0 && done != toBeDone)
				{
					var alpha = HelperFunctions.truncateFloat(done / toBeDone * 100, 2) / 100;
					kadeLogo.alpha = alpha;
					text.alpha = alpha;
					tip.alpha = alpha;
					text.text = "Loading... (" + done + "/" + toBeDone + ")";
				}
			}
		});

		// cache thread
		sys.thread.Thread.create(() ->
		{
			cache();
		});
		#end

		super.create();
	}

	var calledDone = false;

	override function update(elapsed)
	{
		super.update(elapsed);
	}

	function cache()
	{
		#if FEATURE_FILESYSTEM
		trace("LOADING: " + toBeDone + " OBJECTS.");

		for (i in images)
		{
			var replaced = i.replace(".png", "");

			// var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
			var imagePath = Paths.image('characters/$i', 'shared');
			Debug.logTrace('Caching character graphic $i ($imagePath)...');
			var data = OpenFlAssets.getBitmapData(imagePath);
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			graph.destroyOnNoUse = false;
			bitmapData.set(replaced, graph);
			done++;
		}

		for (i in music)
		{
			var inst = Paths.inst(i);
			if (Paths.doesSoundAssetExist(inst))
			{
				FlxG.sound.cache(inst);
			}

			var voices = Paths.voices(i);
			if (Paths.doesSoundAssetExist(voices))
			{
				FlxG.sound.cache(voices);
			}

			done++;
		}

		Debug.logTrace("Finished caching...");

		loaded = true;

		trace(OpenFlAssets.cache.hasBitmapData('GF_assets'));
		#end
		CustomTransition.switchTo(new SplashState());
	}
}
#end
