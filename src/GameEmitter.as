package 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author 
	 */
	public class GameEmitter extends FlxEmitter{
	public var _ownLifespawn:Number = 0;
	
	public var life:Number = 0;
		public function GameEmitter(X:Number = 0, Y:Number = 0, Size:Number = 0)
		{
			super(X, Y, Size);
		}
		
		public function beginEmit(Explode:Boolean = true, Lifespan:Number = 0, Frequency:Number = 0.1, Quantity:uint = 0, ownLifespawn:Number = 0):void
		{
			super.start(Explode, Lifespan, Frequency, Quantity);
			_ownLifespawn = ownLifespawn;
		}
		
		public override function update():void
		{
			super.update();
			_ownLifespawn -= FlxG.elapsed;
			if (_ownLifespawn <= 0)
			{
				on = false;
			}
			
			life += FlxG.elapsed;
			
			if (int( life) % 2 == 0)
			{
				var alive:Boolean = false;
				for each (var obj:FlxSprite in this.members)
				{
					if (obj.alive)
					{
						alive = true;
						break;
					}
				}
				
				if (!alive)
				{
					cleanup();
				}
			}
		}
		
		public function cleanup():void
		{
			kill();
		}
	}
		
	
}