package 
{
	import org.flixel.*;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Glow extends FlxSprite
	{
		[Embed(source = "data/gradient96.png")]	public var GlowMask:Class;
		
		public var darkness:FlxSprite;
		public function Glow(X:Number, Y:Number, Dark:FlxSprite)
		{
			super(X, Y, GlowMask);
			darkness = Dark;
			offset.x = width / 2;
			offset.y = width / 2;
		}
		
		override public function update() : void
		{
			super.update();
			if (y < FlxG.height / 2)
			{
				visible = false;
				return;
			}
			visible = true;
			
		}
		
		override public function draw():void 
		{
			var screenXY:FlxPoint = getScreenXY();
			var darknessScreenXY:FlxPoint = darkness.getScreenXY();
			var stampXY:FlxPoint = new FlxPoint(screenXY.x - (darknessScreenXY.x - darkness.width / 2) - this.width / 2,
						screenXY.y - (darknessScreenXY.y) - this.height / 2);
			//trace(screenXY.x, darknessScreenXY.x);
		  darkness.stamp(this,
						stampXY.x, stampXY.y);
		}
	}
	
}