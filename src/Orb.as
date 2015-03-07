package 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Orb extends FlxSprite 
	{
		[Embed(source = "data/orbSmall.png")]	public var OrbSprite:Class;
		[Embed(source = "data/orbring.png")]	public var OrbRingSprite:Class;
		
		public static const ORB_NAME:String = "orb";
		public static const ORB_NAME_PLURAL:String = "orbs";
		public static const ORB_ARTICLE:String = "an";
		
		public var carried:Boolean = false;
		public var placed:Boolean = false;
		public var holder:OrbHolder;
		
		public static var RING_RADIUS:int = 50;
		private static var RING_BASE_RADIUS:int = 32;
		
		public var glow:Glow;
		public var ring:FlxSprite;
		
		public var RING_ROTATE:Number = 20;
		
		public var rotateSpeed:Number = 0;
		public var ROTATE_SPEED:Number = 30;
		
		public var consuming:Boolean = false;
		public static const CONSUME_SPEED:Number = .4;
		
		public var inMachine:Boolean = false;
		
		public var targetPoint:FlxPoint;
		public var FLY_SPEED:Number = 150;
		
		public function Orb(X:Number, Y:Number)
		{
			super(X, Y);
			loadGraphic(OrbSprite, true, false, 8, 8);
			addAnimation("spin", [0, 1, 2, 3, 4, 5, 6, 7], 8);
			play("spin");
			offset.x = width / 2;
			offset.y = height / 2;
			
			scale.x = 1.5;
			scale.y = 1.5;
			
			glow = new Glow(X, Y, PlayState.instance.darkness);
			
			PlayState.instance.orbGlows.add(glow);
			
			ring = new FlxSprite(X, Y, OrbRingSprite);
			ring.offset.x = ring.width / 2;
			ring.offset.y = ring.height / 2;
			ring.scale.y = ring.scale.x = RING_RADIUS / RING_BASE_RADIUS;
			ring.alpha = .5;
			PlayState.instance.objects.add(ring);
			
			rotateSpeed = Math.random() * ROTATE_SPEED * 2 - ROTATE_SPEED;
			//PlayState.instance.add(glow);
		}
		
		override public function update() : void
		{
			super.update();
			
			angle += FlxG.elapsed * rotateSpeed;
			
			if (!alive)
			{
				ring.visible = false;
				glow.visible = false;
				return;
			}
			
			if (targetPoint != null)
			{
				if (PlayState.getDistance(x, y, targetPoint.x, targetPoint.y) < FLY_SPEED * FlxG.elapsed * 4)
				{
					x = targetPoint.x;
					y = targetPoint.y;
					velocity.x = 0;
					velocity.y = 0;
				}
				else
				{
					var ang:Number = 90 + FlxU.getAngle(new FlxPoint(x, y), targetPoint);
					
					velocity.x = -Math.cos(PlayState.toRadians(ang)) * FLY_SPEED;
					velocity.y = -Math.sin(PlayState.toRadians(ang)) * FLY_SPEED;
				}
			}
			
			glow.x = x;
			glow.y = y;
			
			ring.visible = true;
			glow.visible = true;
			
			if (holder is Tower)
			{
				ring.visible = false;
			}
			if (holder is Machine)
			{
				ring.visible = false;
			}
			
			if (y < FlxG.height / 2)
			{
				ring.visible = false;
			}
			ring.x = x;
			ring.y = y;
			ring.angle += FlxG.elapsed * RING_ROTATE;
			
			if (consuming)
			{
				alpha -= CONSUME_SPEED * FlxG.elapsed;
				if (alpha <= 0)
				{
					kill();
				}
			}
		}
		
		public function get blocksFiends() : Boolean { return (holder != null)};
		
		public function consume() : void
		{
			consuming = true;
		}
		
		override public function kill() : void
		{
			super.kill();
			if (glow != null)
			{
				glow.kill();
			}
		}
		
	}
	
}