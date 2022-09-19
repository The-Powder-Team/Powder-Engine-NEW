package scripts;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.effects.FlxTrail;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar.FlxBarFillDirection;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import hscript.Interp;
import lime.app.Application;
import openfl.Lib;

using StringTools;

// #if VIDEOS_ALLOWED
// import vlc.MP4Sprite;
// import vlc.MP4Handler;
// #end
class ScriptEssentials
{
	// "Halt" is such a fancy word i cant help myself
	public static var HALT_EXECUTION:Int = 0;
	public static var CONTINUE_EXECUTION:Int = 1;

	public static function imports(interp:Interp):Void
	{
		interp.variables.set("CONTINUE_EXECUTION", CONTINUE_EXECUTION);
		interp.variables.set("HALT_EXECUTION", HALT_EXECUTION);

		interp.variables.set("BackgroundDancer", BackgroundDancer);
		interp.variables.set("BackgroundGirls", BackgroundGirls);
		interp.variables.set("FlxAtlasFrames", FlxAtlasFrames);
		interp.variables.set("FlxTypedGroup", FlxTypedGroup);
		interp.variables.set("FlxBackdrop", FlxBackdrop);
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("Application", Application);
		interp.variables.set("FlxParticle", FlxParticle);
		interp.variables.set("FlxEmitter", FlxEmitter);
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("FlxSprite", FlxSprite);
		interp.variables.set("Character", Character);
		interp.variables.set("FlxRandom", FlxRandom);
		interp.variables.set("FlxTween", FlxTween);
		interp.variables.set("FlxTimer", FlxTimer);
		interp.variables.set("FlxTrail", FlxTrail);
		interp.variables.set("FlxSound", FlxSound);
		interp.variables.set("FlxMath", FlxMath);
		interp.variables.set("FlxRect", FlxRect);
		interp.variables.set("FlxEase", FlxEase);
		interp.variables.set("FlxText", FlxText);
		interp.variables.set("Ratings", Ratings);
		interp.variables.set("DiffCalc", DiffCalc);
		interp.variables.set("Paths", Paths);
		interp.variables.set("Boyfriend", Boyfriend);
		interp.variables.set("Math", Math);
		interp.variables.set("Note", Note);
		interp.variables.set("FlxG", FlxG);
		interp.variables.set("Std", Std);
		interp.variables.set("Lib", Lib);

		#if VIDEOS_ALLOWED
		interp.variables.set("VideoSprite", VideoSprite);
		interp.variables.set("VideoHandler", VideoHandler);
		#end

		// interp.variables.set("import", function(classPath:String)
		// {
		// 	importClass(classPath, interp);
		// });
		interp.variables.set("FlxColor", function(huh:String)
		{
			return FlxColor.colorLookup.get(huh);
		});
		interp.variables.set("FlxTextBorderStyle", {
			NONE: FlxTextBorderStyle.NONE,
			SHADOW: FlxTextBorderStyle.SHADOW,
			OUTLINE: FlxTextBorderStyle.OUTLINE,
			OUTLINE_FAST: FlxTextBorderStyle.OUTLINE_FAST
		});
		interp.variables.set("FlxTextAlign", {
			CENTER: FlxTextAlign.CENTER,
			LEFT: FlxTextAlign.LEFT,
			RIGHT: FlxTextAlign.RIGHT,
			JUSTIFY: FlxTextAlign.JUSTIFY
		});
		interp.variables.set("FlxAxes", {
			X: X,
			Y: Y,
			XY: XY,
		});
		interp.variables.set("FlxTweenType", {
			PERSIST: FlxTweenType.PERSIST,
			LOOPING: FlxTweenType.LOOPING,
			PINGPONG: FlxTweenType.PINGPONG,
			ONESHOT: FlxTweenType.ONESHOT,
			BACKWARD: FlxTweenType.BACKWARD
		});
		interp.variables.set("print", function(e:Dynamic)
		{
			Main.console.add(e, CONSOLE);
		});
		interp.variables.set("FlxBarFillDirection", {
			LEFT_TO_RIGHT: LEFT_TO_RIGHT,
			RIGHT_TO_LEFT: RIGHT_TO_LEFT
		});
		interp.variables.set("FlxEmitterMode", {
			SQUARE: FlxEmitterMode.SQUARE,
			CIRCLE: FlxEmitterMode.CIRCLE
		});

		interp.variables.set("add", FlxG.state.subState != null ? FlxG.state.subState.add : FlxG.state.add);
		interp.variables.set("remove", FlxG.state.subState != null ? FlxG.state.subState.remove : FlxG.state.remove);
		interp.variables.set("insert", FlxG.state.subState != null ? FlxG.state.subState.insert : FlxG.state.insert);
	}

	static function importClass(classPath:String, interp:Interp):Void
	{
		if (classPath.toLowerCase().trim().startsWith("sys"))
		{
			Main.console.add("\"sys\" imports are not allowed!", GAME);
			return;
		}

		var classLol = Type.resolveClass(classPath);

		if (classLol == null)
		{
			Main.console.add("Import " + classPath + " does not exist!");
			return;
		}
		var className = Type.getClassName(classLol).split(".").pop().trim();

		interp.variables.set(className, classLol);
	}
}
