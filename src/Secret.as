package 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Secret extends NPC 
	{
		[Embed(source = "data/secret.png")]	public var SecretSprite:Class;
		
		public function Secret(X:Number, Y:Number)
		{
			super(X, PlayState.instance.world.y, World.LIGHT);
			loadGraphic(SecretSprite, true, true, 16, 16);
			offset.y = height;
			offset.x = width / 2;
			scale.x = scale.y = 2;
			y -= 8;
			
			addAnimation("stand", [0]);
			addAnimation("walk", [1, 2, 3], 6, true);
			play("stand");
			facing = RIGHT;
			usesDefaultAnimations = false;
			setGameState(WALK);
		}
		
		override public function update() : void
		{
			super.update();
			if (velocity.x != 0)
			{
				play("walk");
			}
			
			if (target != null && Math.abs(target.x - x) < 5)
			{
				PlayState.instance.waitingForSecret = false;
				setGameState(END);
			}
		}
		
		override protected function getRandomTarget() : FlxObject
		{
			return new FlxObject(PlayState.instance.world.x + World.MAX_DISTANCE * 1.2, PlayState.instance.world.y);
		}
	}
	
}