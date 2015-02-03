package 
{
	
	/**
	 * ...
	 * @author zillix
	 */
	import org.flixel.*;
	 
	 public class LightPlayer extends Player 
	{
		[Embed(source = "data/lightplayerSmall.png")]	public var LightPlayerSprite:Class;
		
		public function LightPlayer(X:Number, Y:Number)
		{
			super(X, Y, World.LIGHT);
			loadGraphic(LightPlayerSprite, true, true, 20, 64);
			scale.x = scale.y = 2;
			offset.x = width / 2;
			offset.y = height * 3 / 2;
			addAnimation("stand", [0]);
			addAnimation("walk", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 16);
			addAnimation("kneel", [0, 10, 11, 12], 4, false);
			addAnimation("rise", [12, 11, 10, 0], 4, false);
			play("stand");
		}
		
		override public function update() : void
		{
			super.update();
		}
		
		override public function get armsY() : Number { return y - 80; }
		
		override public function get leftPressed() : Boolean { return FlxG.keys.LEFT; }
		override public function get rightPressed() : Boolean { return FlxG.keys.RIGHT; }
		override public function get downPressed() : Boolean { return FlxG.keys.DOWN; }
		override public function get upPressed() : Boolean { return FlxG.keys.UP; }
		
	}
	
}