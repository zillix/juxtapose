package 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Zillix
	 */
	public class GameParticle extends FlxParticle 
	{
		public var state:int;
		public function GameParticle(State:int, c:Number = 0)
		{
			if (c == 0)
			{
				if (State == World.LIGHT)
				{
					c = 0xff000000;
				}
				else
				{
					c = 0xffffffff;
				}
			}
			super();
			this.makeGraphic(2, 2, c);
			this.offset.x = width / 2;
			this.offset.y = height / 2;
			
			state = State;
		}
		
		override public function update() : void
		{
			super.update();
			if (state == World.LIGHT)
			{
				if (y + velocity.y * FlxG.elapsed > PlayState.instance.world.y)
				{
					y = PlayState.instance.world.y - scale.y;
					velocity.x = 0;
					velocity.y = 0;
				}
			}
			if (state == World.DARK)
			{
				if (y  + velocity.y * FlxG.elapsed < PlayState.instance.world.y)
				{
					y = PlayState.instance.world.y + scale.y;
					velocity.x = 0;
					velocity.y = 0;
				}
			}
		}
		
		override public function onEmit():void
		{
			angularVelocity = 0;
		}
	}
	
}