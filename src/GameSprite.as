package 
{
	import flash.geom.Rectangle;
	import org.flixel.*;
	/**
	 * ...
	 * @author zillix
	 */
	public class GameSprite extends FlxSprite
	{
		public var examineTime:Number = 2;
		public var state:int;
		public function GameSprite(X:Number, Y:Number, S:int)
		{
			state = S;
			super(X, Y);
			
		}
		
		override public function loadGraphic(Graphic:Class, Animated:Boolean = false, Reverse:Boolean = false, Width:uint = 0, Height:uint = 0, Unique:Boolean = false) : FlxSprite
		{
			var returnValue:FlxSprite = super.loadGraphic(Graphic, Animated, Reverse, Width, Height, Unique);
			
			if (state == World.LIGHT)
			{
				offset.y = height;
			}
			offset.x = width / 2;
			
			return returnValue;
		}
		
		public function onStateChanged(newState:int) : void { }
		
		public function getHitbox() : Rectangle { return new Rectangle(x - offset.x, y - offset.y, width, height); }
		
		public function simpleOverlapCheck(gameSprite:GameSprite) : Boolean
		{
			var myBox:Rectangle = getHitbox();
			var theirBox:Rectangle = gameSprite.getHitbox();
			return	(theirBox.x + theirBox.width > myBox.x) && (theirBox.x < myBox.x + myBox.width) &&
						(theirBox.y + theirBox.height > myBox.y) && (theirBox.y < myBox.y + myBox.height);
		}
		
		public function emitParticle(emitterX:Number, emitterY:Number, particleCount:int, explode:Boolean = true, color:uint = 0, lifeSpan:Number = 1, frequency:Number = 0, quantity:int = 0, ownLifespan:Number = 0, particleScale:Number = 1) : void
		{
			var emitter:GameEmitter = new GameEmitter(emitterX, emitterY, particleCount);
			emitter.gravity = isLight ? World.GRAVITY : -World.GRAVITY;
			var particle:GameParticle;
			for (var i:int = 0; i < particleCount; i++)
			{
				particle = new GameParticle(state, color);
				particle.scale.x = particle.scale.y = particleScale;
				emitter.add(particle);
			}
			
			PlayState.instance.emitters.add(emitter);
			emitter.beginEmit(explode, lifeSpan, frequency, quantity, ownLifespan);
		}
		
		public function get isLight() : Boolean { return state == World.LIGHT; }
		public function get isDark() : Boolean { return state == World.DARK; }
		
		public function get canExamine() : Boolean { return !PlayState.instance.hasPendingEnding; }
		
		public function examine() : void
		{
			PlayState.instance.queueText(getExamineText());
		}
		
		public function get examineString() : String { return "examine"; }
		
		public function getExamineText() : Vector.<PlayText> { return null }
		
		
		
		protected function addText(vec:Vector.<PlayText>, text:String, duration:int = -1) : void
		{
			if (duration < 0)
			{
				duration = PlayText.DEFAULT_DURATION;
			}
			
			vec.push(new PlayText(text, duration));
		}
		
		public function get isActive() : Boolean { return state == PlayState.instance.state; }
	}
	
}