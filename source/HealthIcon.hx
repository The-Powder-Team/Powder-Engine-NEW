package;

import flixel.FlxG;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var char:String = 'bf';
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;

	public var lossIndex:Int = -1;
	public var neutralIndex:Int = 0;
	public var winningIndex:Int = -1;

	var charArray:Array<Int> = [];

	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(?char:String = "bf", ?isPlayer:Bool = false)
	{
		super();

		this.char = char;
		this.isPlayer = isPlayer;

		isPlayer = isOldIcon = false;

		changeIcon(char);
		scrollFactor.set();
	}

	public function swapOldIcon()
	{
		(isOldIcon = !isOldIcon) ? changeIcon("bf-old") : changeIcon(char);
	}

	public function changeIcon(char:String)
	{
		if (char != 'bf-pixel' && char != 'bf-old')
			char = char.split("-")[0];

		if (!OpenFlAssets.exists(Paths.image('icons/icon-' + char)))
			char = 'face';

		for (w in 0...Math.floor(width / 150))
		{
			charArray.push(w);
		}
		loadGraphic('icons/icon-' + char, true, 150, 150);
		switch (charArray.length)
		{
			case 1:

			case 2:
				neutralIndex = 0;
				lossIndex = 1;
			case 3:
				lossIndex = 0;
				neutralIndex = 1;
				winningIndex = 2;
		}
		if (char == 'senpai' || char == 'spirit' || char.contains("pixel"))
		{
			antialiasing = false;
		}
		else
		{
			antialiasing = true;
		}
		animation.add('icon', charArray, 0, false);
		animation.play('icon', true);
		if (animation.curAnim != null)
			animation.curAnim.curFrame = neutralIndex;

		width = 150;
		height = 150;
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
