package scripts;

import flixel.FlxG;
import flixel.util.FlxStringUtil;
import hscript.Interp;
import hscript.Parser;
import lime.ui.KeyCode;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.ui.Keyboard;

using StringTools;

enum abstract ConsolePrefix(String) to String
{
	var GAME = "Powder Engine";
	var CONSOLE = "Console";
	var EXECUTE = "Execute";
	var PLAYSTATE = "PlayState";
	var TITLESTATE = "TitleState";
	var FREEPLAY = "FreeplayState";
	var STORYMENU = "StoryMenuState";
	var CREDITS = "CreditsMenu";
	var BINDS = "KeybindMenu";
	var MAINMENU = "MainMenuState";
	var OPTIONS = "OptionsState";
	var SPLASH = "SplashState";
	var PAUSEMENU = "PauseSubState";
	// if you have remade a complicated menu like the options menu or the fucking PLAYSTATE itself, I will respect you 100%
	// ykw remake ADOFAI in Funkin' it would be funny lmao
}

class ScriptConsole extends Sprite
{
	var lmaos:Array<String> = [
		"Inspired by Yoshi Engine and Hope Engine :tm:",
		"hacker :sunglasses: wow so cool",
		"I added nothing in this update!",
		"Hi dev smile",
		"Holy shit.",
		"Everything. By everyone.",
		"Left... down... up... right...",
		"WAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa",
		"Now with more bugs!",
		"Now with more crashes!",
		"We out here",
		"Roblox dev console type beat",
		"Apple",
		"while (true) {}",
		"Sys.exit(0) :troll:",
		"We are gaming my peoplpe",
		"2 steps ahead.",
		"Connection terminated.",
		"Clown to clown communication",
		"Rust. Oxidized, even.",
		"cock",
		"Pretty much.",
		"",
		"",
		"",
		""
	];

	public var history:Array<String> = [];
	public var content:TextField;
	public var commandLine:TextField;

	var placeholder:TextField;
	var historyDisplay:TextField;

	public var interp:Interp;
	public var parser:Parser;

	var consoleText:String = " | Press ALT + R to clear console.";

	public function new()
	{
		super();

		interp = new Interp();

		parser = new Parser();
		parser.allowTypes = true;
		parser.allowJSON = true;
		parser.allowMetadata = true;
		parser.resumeErrors = true;

		var tmp:Bitmap = new Bitmap(new BitmapData(FlxG.width, FlxG.height, true, 0x7F000000));
		screenCenter();
		addChild(tmp);

		content = new TextField();
		content.width = FlxG.width - 32;
		content.height = FlxG.height - 68;
		var a = new TextFormat("VCR OSD Mono", 24, 0xFFFFFF);
		a.align = TextFormatAlign.LEFT;
		content.defaultTextFormat = a;
		content.text = "Console time. " + FlxG.random.getObject(lmaos);
		content.x = x + 16;
		content.y = y + 16;
		content.selectable = false;
		content.wordWrap = true;
		addChild(content);

		var tmp2 = new Bitmap(new BitmapData(FlxG.width - 32, 32, true, 0xFFFFFFFF));
		tmp2.x = content.x;
		tmp2.y = content.y + content.height + 4;
		screenCenter();
		addChild(tmp2);

		var title:TextField = new TextField();
		title.width = FlxG.width - 32;
		title.height = 26;
		var a = new TextFormat("VCR OSD Mono", 24, 0xcecece);
		a.align = TextFormatAlign.RIGHT;
		title.defaultTextFormat = a;
		title.text = "Powder Engine v" + MainMenuState.powderEngineVer;
		title.x = x + 16;
		title.y = y + 16;
		title.selectable = false;
		addChild(title);

		var subtitle:TextField = new TextField();
		subtitle.width = FlxG.width - 32;
		subtitle.height = 64;
		var a = new TextFormat("VCR OSD Mono", 22, 0x969696);
		a.align = TextFormatAlign.RIGHT;
		subtitle.defaultTextFormat = a;
		subtitle.text = "Awesome and Cool Console\nPress [F3] to close";
		subtitle.x = x + 16;
		subtitle.y = y + title.y + title.height;
		subtitle.selectable = false;
		addChild(subtitle);

		commandLine = new TextField();
		commandLine.width = tmp2.width - 8;
		commandLine.height = tmp2.height - 8;
		var a = new TextFormat("VCR OSD Mono", 24, 0xFF252525);
		a.align = TextFormatAlign.LEFT;
		commandLine.defaultTextFormat = a;
		commandLine.text = "";
		commandLine.multiline = false;
		commandLine.type = TextFieldType.INPUT;
		commandLine.x = tmp2.x + 4;
		commandLine.y = tmp2.y + 4;
		commandLine.selectable = true;

		placeholder = new TextField();
		placeholder.width = tmp2.width - 8;
		placeholder.height = tmp2.height - 8;
		var a = new TextFormat("VCR OSD Mono", 24, 0xFF696969);
		a.align = TextFormatAlign.LEFT;
		placeholder.defaultTextFormat = a;
		placeholder.text = "HScript Interpreter. Add some HScript here!";
		placeholder.multiline = false;
		placeholder.type = TextFieldType.INPUT;
		placeholder.x = tmp2.x + 4;
		placeholder.y = tmp2.y + 4;
		placeholder.selectable = false;
		placeholder.visible = false;

		historyDisplay = new TextField();
		historyDisplay.width = tmp2.width;
		historyDisplay.height = 18;
		var a = new TextFormat("VCR OSD Mono", 16, 0xFFFFFFFF);
		a.align = TextFormatAlign.RIGHT;
		historyDisplay.defaultTextFormat = a;
		historyDisplay.text = "History: 0 (Press ALT + C to clear)" + consoleText;
		historyDisplay.multiline = false;
		historyDisplay.type = TextFieldType.INPUT;
		historyDisplay.x = tmp2.x;
		historyDisplay.y = tmp2.y - historyDisplay.height;
		historyDisplay.selectable = false;

		addChild(historyDisplay);
		addChild(placeholder);
		addChild(commandLine);

		var wasInvi:Bool = false;

		FlxG.signals.postUpdate.add(function()
		{
			scaleX = FlxG.scaleMode.scale.x;
			scaleY = FlxG.scaleMode.scale.y;

			x = FlxG.scaleMode.offset.x;
			y = FlxG.scaleMode.offset.y;

			if (FlxG.keys.justPressed.F3)
			{
				visible = !visible;

				if (visible)
				{
					if (!FlxG.mouse.visible)
					{
						FlxG.mouse.visible = true;
						wasInvi = true;
					}
					else
						wasInvi = false;
				}

				if (wasInvi && !visible)
					FlxG.mouse.visible = false;
			}

			placeholder.visible = commandLine.length < 1 && !isTextFocused;
			historyDisplay.text = "History: " + history.length + " (Press ALT + C to clear)" + consoleText;
		});

		content.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownScroll);
		content.addEventListener(MouseEvent.MOUSE_UP, mouseUpScroll);

		commandLine.addEventListener(FocusEvent.FOCUS_IN, onFocus);
		commandLine.addEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		commandLine.addEventListener(KeyboardEvent.KEY_DOWN, onKey);

		visible = false;
	}

	var _scrollLocked:Bool = false;
	var isTextFocused:Bool = false;

	public function add(m:Dynamic, ?prefix:ConsolePrefix = GAME):Void
	{
		var hours = Date.now().getHours() % 12 + "";
		var mins = Date.now().getMinutes() + "";
		var seconds = Date.now().getSeconds() + "";

		if (mins.length == 1)
			mins = "0" + mins;

		if (seconds.length == 1)
			seconds = "0" + seconds;

		content.text += (content.length > 0 ? "\n" : "") + '[$hours:$mins:$seconds] [$prefix] ' + m;
		content.scrollV = content.scrollV;

		if (content.scrollV + 1 == content.maxScrollV)
			content.scrollV = content.maxScrollV;
	}

	public function clear():Void
		content.text = "";

	public function mouseUpScroll(e:MouseEvent):Void
	{
		content.scrollV--;
	}

	public function mouseDownScroll(e:MouseEvent):Void
	{
		content.scrollV++;
	}

	public function screenCenter():Void
	{
		x = (0.5 * (Lib.current.stage.stageWidth - FlxG.width) - FlxG.game.x);
	}

	function onFocus(e:FocusEvent):Void
	{
		isTextFocused = true;
		FlxG.keys.enabled = false;
	}

	function onFocusLost(e:FocusEvent):Void
	{
		isTextFocused = false;
		FlxG.keys.enabled = true;
	}

	function execute(hscript:String):Void
	{
		history.insert(0, hscript);
		curSelected = -1;
		commandLine.text = "";

		var ast = parser.parseString(hscript);
		add(hscript, EXECUTE);
		ScriptEssentials.imports(interp);

		try
		{
			interp.execute(ast);
		}
		catch (e:Dynamic)
		{
			add(e, CONSOLE);
		}
	}

	var curSelected:Int = -1;

	function onKey(e:KeyboardEvent):Void
	{
		if (e.keyCode == Keyboard.ENTER && commandLine.text.toString().trim().length > 0)
		{
			execute(commandLine.text.toString().trim());
			content.scrollV = content.maxScrollV;
		}

		if ((e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN) && history.length > 0)
		{
			if (e.keyCode == Keyboard.UP)
				curSelected++;
			if (e.keyCode == Keyboard.DOWN)
				curSelected--;

			if (curSelected < -1)
				curSelected = 1;

			if (curSelected > history.length - 1)
				curSelected = history.length - 1;

			if (curSelected >= 0)
			{
				commandLine.text = "";
				commandLine.appendText(history[curSelected]);
			}
			else
				commandLine.text = "";
		}

		if (e.altKey)
		{
			switch (e.keyCode)
			{
				case Keyboard.C:
					history = [];
					curSelected = -1;
					commandLine.text = "";
				case Keyboard.R:
					clear();
			}
		}
	}
}
