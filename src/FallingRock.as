package 
{
	import org.flixel.*;
	/**
	 * ...
	 * @author zillix
	 */
	public class FallingRock extends GameSprite
	{
		[Embed(source = "data/rock.png")]	public var RockSprite:Class;
		
		public var fading:Boolean = false;
		
		public function FallingRock(X:Number, Y:Number)
		{
			super(X, Y, World.LIGHT);
			loadGraphic(RockSprite, false, true);
			facing = Math.random() < .5 ? LEFT : RIGHT;
			angularVelocity = 5;
			acceleration.y = World.GRAVITY;
		}
		
		override public function update() : void
		{
			super.update();
			
			if (fading)
			{
				alpha -= FlxG.elapsed;
				if (alive && alpha <= 0)
				{
					kill();
				}
			}
			
			var targetY:int = PlayState.instance.world.y - 88; // height of the portal, I think
			if (!fading && velocity.y * FlxG.elapsed + y > targetY)
			{
				bounce();
			}
		}
		
		public function bounce() : void
		{
			velocity.x = Math.random() * 50 - 25;
			velocity.y = -20 - Math.random() * 20;
			fading = true;
			
			var machin:Machine = PlayState.instance.getMachine(World.LIGHT)
			if (machin != null)
			{
				machin.damageMachine();
			}
		}
		
	}
	
}