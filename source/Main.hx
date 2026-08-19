package;

import flixel.FlxGame;
import lime.app.Application;
import openfl.display.Sprite;
import openfl.geom.Point;

class Main extends Sprite
{
	public function new()
	{
		super();

		addChild(new FlxGame(0, 0, PlayState,
			Application.current.window.displayMode.refreshRate, Application.current.window.displayMode.refreshRate,
			true,
			false
		));
	}
}
