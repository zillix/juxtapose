package 
{
	import org.flixel.*;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class InvertGlow extends FlxSprite
	{
		[Embed(source = "data/invertGradient.png")]	public var GlowMask:Class;
		
		private var expandVelocity:Number = 200;
		private var expandAcceleration:Number = -100;
		private var radius:Number = 0;
		private var DEFAULT_RADIUS:Number = 100;
		
		public function InvertGlow(X:Number, Y:Number)
		{
			super(X, Y, GlowMask);
			offset.x = width / 2;
			offset.y = width / 2;
			blend = "invert";
			
			scale.x = radius / DEFAULT_RADIUS;
			scale.y = scale.x;
		}
		
		override public function update() : void
		{
			super.update();
			
			if (radius < 0)
			{
				return;
			}
			
			scale.x = radius / DEFAULT_RADIUS;
			scale.y = scale.x;
			
			radius += FlxG.elapsed * expandVelocity;
			expandVelocity += FlxG.elapsed * expandAcceleration;
			
			if (radius < 0)
			{
				kill();
			}
			
			
			
		}
	}
	
}