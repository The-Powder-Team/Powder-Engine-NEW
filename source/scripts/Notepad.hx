package scripts;

import flixel.FlxG;
import hscript.Expr;
import hscript.Parser;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.ui.Keyboard;
import sys.io.File;

using StringTools;

// Completing this soon - though it's a starter
// It's just quick-access notepad at this point
class Notepad extends Sprite
{
	public var content:TextField;

	var json:String;
	var path:String;

	var parser:Parser;

	public function new(json:String, width:Int, height:Int, path:String)
	{
		super();

		parser = new Parser();
		parser.allowTypes = true;
		parser.allowJSON = true;
		parser.allowMetadata = true;

		this.json = json;
		this.path = path;

		content = new TextField();
		content.x = 64;
		content.width = width - 64;
		content.height = height;
		var a = new TextFormat("VCR OSD Mono", 22, 0xffffff);
		a.align = TextFormatAlign.LEFT;
		content.defaultTextFormat = a;
		content.text = File.getContent(Paths.charJson(path));
		// what the flick are you???
		content.text = content.text.replace("\r", "");
		content.multiline = true;
		content.type = TextFieldType.INPUT;
		content.selectable = true;
		addChild(content);

		content.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		content.addEventListener(Event.ENTER_FRAME, onFrameEnter);
	}

	var parsed:Bool = false;
	var parseTime:Float = 0.0;

	function onFrameEnter(e:Event)
	{
		if (parseTime > 0 && !parsed)
			parseTime -= FlxG.elapsed;

		if (parseTime < 0 && !parsed)
		{
			parseTime = 0;
			parsed = true;
			try
			{
				parse();
				stage.window.title = "Powder Engine Character JSON Editor";
			}
			catch (e:Dynamic)
			{
				stage.window.title = "Powder Engine Character JSON Editor - [ERROR] " + e;
			}
		}
	}

	function parse()
	{
		parser.parseString(content.text.toString());
	}

	function onKey(k:KeyboardEvent)
	{
		if (k.keyCode == Keyboard.S && k.controlKey)
			File.saveContent(Paths.charJson(path), content.text.toString().trim());

		parseTime = 1.5;
		parsed = false;
	}

	public function mouseUpScroll(e:MouseEvent):Void
	{
		if (e.shiftKey)
			content.scrollH--;
	}

	public function mouseDownScroll(e:MouseEvent):Void
	{
		if (e.shiftKey)
			content.scrollH++;
	}
}
