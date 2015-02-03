package 
{
	import org.flixel.*;
	/**
	 * ...
	 * @author zillix
	 */
	public class Seed extends GameSprite
	{
		[Embed(source = "data/seed.png")]	public var SeedSprite:Class;
		[Embed(source = "data/seedDrop.mp3")]	public var SeedDropSound:Class;
		
		public static const GROW_TIME:int = 1;
		public var growTime:Number = GROW_TIME;
		public var secret:Boolean = false;
		public function Seed(X:Number, Y:Number)
		{
			super(X, Y, World.LIGHT);
			loadGraphic(SeedSprite, true, false, 8, 8);
			addAnimation("grow", [0, 1, 2], 3, false);
			play("grow");
		}
		
		override public function update() : void
		{
			super.update();
			if (growTime > 0)
			{
				growTime -= FlxG.elapsed;
				if (growTime <= 0)
				{
					acceleration.y = World.GRAVITY;
					FlxG.play(SeedDropSound, PlayState.SFX_VOLUME);
				}
			}
			if (y >= PlayState.instance.world.y)
			{
				velocity.y = 0;
				acceleration.y = 0;
				kill();
				
				if (!secret)
				{
					PlayState.instance.spawnPlant(x, y);
				}
				else
				{
					PlayState.instance.spawnSecret(x, y);
				}
			}
		}
		
	}
	
}