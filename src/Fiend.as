package 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Fiend extends GameSprite 
	{
		[Embed(source = "data/fiend.png")]	public var FiendSprite:Class;
		
		public var targetPoint:FlxPoint;
		
		public static const FLY_SPEED:Number = 300;
		public static const EXPLODE_DIST:int = 5;
		public var targetAngle:Number;
		
		public function Fiend(X:Number, Y:Number, state:int)
		{
			super(X, Y, state);
			loadGraphic(FiendSprite);
			offset.x = width / 2;
			offset.y = height / 2;
			
			targetPoint = new FlxPoint(Math.random() * World.MAX_DISTANCE * 2 - World.MAX_DISTANCE + PlayState.instance.world.x,
				PlayState.instance.world.y);
			targetAngle = 270 + FlxU.getAngle(new FlxPoint(x, y), targetPoint);
			
			velocity.x = Math.cos(PlayState.toRadians(targetAngle)) * FLY_SPEED;
			velocity.y = Math.sin(PlayState.toRadians(targetAngle)) * FLY_SPEED;
		}
		
		override public function update() : void
		{
			super.update();
			
			if (!alive)
			{
				return;
			}
			
			if (y + velocity.y * FlxG.elapsed < PlayState.instance.world.y)
			{
				explode();
			}
			
			for each (var orb:Orb in PlayState.instance.backgroundOrbs.members)
			{
				if (orb && orb.blocksFiends && PlayState.getDistance(x, y, orb.x, orb.y) < Orb.RING_RADIUS)
				{
					explode();
					break;
				}
			}
			
			/*for each (var plant:Plant in PlayState.instance.plants.members)
			{
				if (plant.simpleOverlapCheck(this))
				{
					explode();
					plant.onEnemyHit(this);
					break;
				}
			}*/
			
			for each (var npc:NPC in PlayState.instance.npcs.members)
			{
				if (npc.state != state)
				{
					continue;
				}
				
				if (npc.simpleOverlapCheck(this))
				{
					explode();
					npc.onEnemyHit(this);
					break;
				}
			}
		}
		
		public function explode() : void
		{
			if (!alive)
			{
				return;
			}
			
			// Play a cool animation
			kill();
		}
		
	}
	
}