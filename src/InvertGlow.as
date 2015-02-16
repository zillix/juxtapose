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
		
		private var DEFAULT_EXPAND_VELOCITY:Number = 200;
		private var expandVelocity:Number = 0;
		private var expandAcceleration:Number = -140;
		public var radius:Number = 0;
		private var DEFAULT_RADIUS:Number = 100;
		private var magnitude:int = 1;
		
		public function InvertGlow(X:Number, Y:Number)
		{
			super(X, Y, GlowMask);
			offset.x = width / 2;
			offset.y = width / 2;
			blend = "invert";
			
			scale.x = radius / DEFAULT_RADIUS;
			scale.y = scale.x;
		}
		
		public function pulse(magnitude:int) : void
		{
			this.magnitude = magnitude;
			expandVelocity = DEFAULT_EXPAND_VELOCITY * ((magnitude - 1) / 4 + 1);
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
			
			if (expandVelocity == 0)
			{
				return;
			}
			
			radius += FlxG.elapsed * expandVelocity;
			expandVelocity += FlxG.elapsed * expandAcceleration;
			
			if (radius < 0)
			{
				kill();
			}
			
			
			
		}
	}
	
}