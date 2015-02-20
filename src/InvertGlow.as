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
		public var expandVelocity:Number = 0;
		private var expandAcceleration:Number = -140;
		public var radius:Number = 0;
		private var DEFAULT_RADIUS:Number = 100;
		private var magnitude:int = 1;
		private var minRadius:Number = 0;
		
		private var STATE_PULSING:int = 0;
		public var STATE_IDLE:int = 1;
		private var STATE_OFF:int = 2;
		public var STATE_PULSED:int = 3;
		
		public var state:int = STATE_OFF;
		
		private var idleAngle:Number = 0;
		private var idleAngleVel:Number = 200;
		private var idleMagnitude:Number = 10;
		
		public function InvertGlow(X:Number, Y:Number)
		{
			super(X, Y, GlowMask);
			offset.x = width / 2;
			offset.y = width / 2;
			blend = "invert";
			
			scale.x = radius / DEFAULT_RADIUS;
			scale.y = scale.x;
		}
		
		public function pulse(magnitude:int, minRadius:Number = 0) : void
		{
			state = STATE_PULSING;
			this.magnitude = magnitude;
			expandVelocity = DEFAULT_EXPAND_VELOCITY * ((magnitude - 1) / 4 + 1);
			this.minRadius = minRadius;
		}
		
		public function beginIdle() : void
		{
			idleAngle = 180;
			state = STATE_IDLE;
		}
		
		override public function update() : void
		{
			super.update();
			
			if (state == STATE_IDLE)
			{
				idleAngle += FlxG.elapsed * idleAngleVel;
			}
			else
			{
				idleAngle = 0;
			}
			
			
			if (state == STATE_PULSING)
			{
				radius += FlxG.elapsed * expandVelocity;
				expandVelocity += FlxG.elapsed * expandAcceleration;
			}
			scale.x = (radius + (Math.sin(PlayState.toRadians(idleAngle)) * idleMagnitude)) / DEFAULT_RADIUS;
			scale.y = scale.x;
			
			
			if (state == STATE_PULSING && radius < minRadius && expandVelocity < 0)
			{
				state = STATE_PULSED;
				radius = minRadius;
				expandVelocity = 0;
				//kill();
			}
			
			
			
		}
	}
	
}