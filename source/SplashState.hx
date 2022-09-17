package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

/**
 * Taken from this
 * https://github.com/ninjamuffin99/HFSplashTemplate
 * 
 * @author ninjamuffin99
 */
class SplashState extends MusicBeatState
{
	private var _times:Array<Float>;
	private var _curPart:Int = 0;
	private var _functions:Array<Void->Void>;

	var logo:FlxSprite;

	var topText:FlxText;
	var botText:FlxText;

	override public function create():Void
	{
		new FlxTimer().start(1.5, function(tmr:FlxTimer)
		{
			FlxG.fixedTimestep = false;

			// These are when the flixel notes/sounds play, you probably shouldn't change these if you want the functions to sync up properly
			_times = [0.041, 0.184, 0.334, 0.495, 0.636];

			// An array of functions to call after each time thing has passed, feel free to rename to whatever
			_functions = [addText1, addText2, addText3, addText4, addText5];

			for (time in _times)
			{
				new FlxTimer().start(time, timerCallback);
			}

			logo = new FlxSprite().loadGraphic(Paths.image("haxeflixel", "preload"), true, 720, 720);
			logo.animation.add('lgoo', [0, 1, 2, 3, 4], 0, false);
			logo.animation.play('lgoo');
			logo.scale.set(0.25, 0.25);
			logo.updateHitbox();
			logo.screenCenter();
			logo.antialiasing = true;
			logo.visible = false;
			add(logo);

			topText = new FlxText(0, 0, 0, "Made with");
			topText.size = 32;
			topText.alignment = CENTER;
			topText.screenCenter(X);
			topText.y = logo.y - topText.height - 8;
			add(topText);

			topText.fieldWidth = topText.width;
			topText.text = "";
			topText.alignment = LEFT;

			botText = new FlxText(0, 0, 0, "HaxeFlixel");
			botText.size = 32;
			botText.alignment = CENTER;
			botText.screenCenter(X);
			botText.y = logo.y + logo.height + 8;
			add(botText);

			botText.fieldWidth = botText.width;
			botText.text = "";
			botText.alignment = LEFT;

			// put the included flixel.mp3 into your assests folder in your project
			FlxG.sound.play(Paths.sound("flixel", "shared"), 0.6, false, null, true);
		});
		super.create();
	}

	var DONTFUCKINGTRIGGERYOUPIECEOFSHIT:Bool = false;

	override public function update(elapsed:Float):Void
	{
		// Thing to skip the splash screen
		// Comment this out if you want it unskippable

		if (DONTFUCKINGTRIGGERYOUPIECEOFSHIT)
			return;

		if (FlxG.keys.justPressed.ANY)
		{
			finishTween();
		}

		super.update(elapsed);
	}

	private function timerCallback(Timer:FlxTimer):Void
	{
		_functions[_curPart]();

		logo.visible = true;
		logo.animation.curAnim.curFrame = _curPart;

		_curPart++;

		if (_curPart == 5)
		{
			// What happens when the final sound/timer time passes
			// change parameters to whatever you feel like
			new FlxTimer().start(0.25, function(_)
			{
				FlxG.camera.fade(FlxColor.BLACK, 3.25, false, finishTween);
			});
		}
	}

	private function addText1():Void
	{
		// stuff that happens
		topText.text = "Made";
	}

	private function addText2():Void
	{
		// stuff that happens
		topText.text = "Made with";
	}

	private function addText3():Void
	{
		// stuff that happens
		botText.text = "Haxe";
	}

	private function addText4():Void
	{
		// stuff that happens
		botText.text = "HaxeFlix";
	}

	private function addText5():Void
	{
		// stuff that happens
		botText.text = "HaxeFlixel";
	}

	private function finishTween():Void
	{
		// Switches to MenuState when the fadeout tween(in the timerCallback function) is finished
		FlxG.switchState(new TitleState());
	}
}
