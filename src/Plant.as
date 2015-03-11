package 
{
	import flash.accessibility.AccessibilityImplementation;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import org.flixel.*;
	import com.newgrounds.API;
	/**
	 * ...
	 * @author zillix
	 */
	public class Plant extends HittableSprite
	{
		[Embed(source = "data/plantBW.png")]	public var PlantSprite:Class;
		
		public var growth:int = 1;
		
		public static const MAX_GROWTH:int = 4;
		
		public var hitboxes:Vector.<FlxPoint>;
		
		public var secretOffset:FlxPoint = new FlxPoint(27, -45);
		
		public function Plant(X:Number, Y:Number)
		{
			super(X, Y, World.BOTH);
			loadGraphic(PlantSprite, true, false, 30, 76);
			
			scale.x = 2;
			scale.y = 2;
			offset.x = width / 2;
			offset.y = height / 2 - scale.x;
		
			addAnimation("0", [0, 1], 1);
			addAnimation("1", [2, 3], 1);
			addAnimation("2", [4, 5], 1);
			addAnimation("3", [6, 7], 1);
			addAnimation("4", [8, 9], 1);
			
			play("1");
			
			hitboxes = new Vector.<FlxPoint>();
			hitboxes[0] = new FlxPoint(0, 0);
			hitboxes[1] = new FlxPoint(4 * scale.x, 12 * scale.y);
			hitboxes[2] = new FlxPoint(8 * scale.x, 30 * scale.y);
			hitboxes[3] = new FlxPoint(8 * scale.x, 38 * scale.y);
			hitboxes[4] = new FlxPoint(6 * scale.x, 60 * scale.y);
		}
		
		override public function update() : void
		{
			super.update();
		}
		
		override public function onStateChanged(newState:int) : void
		{
			super.onStateChanged(newState);
			enemyHits = 0;
			
			if (newState == World.LIGHT)
			{
				if (growth > 0)
				{
					grow();
					
					
				}
			}
		}
		
		public function grow() : void
		{
			var logGrowth:Boolean = growth < MAX_GROWTH;
			growth = Math.min(growth + 1, MAX_GROWTH);
			play(growth.toString());
			
			if (logGrowth)
			{
				API.logCustomEvent("tree_growth_" + growth);
			}
			
		}
		
		
		override public function getHitbox() : Rectangle
		{
			var box:Rectangle = super.getHitbox();
			box.width = hitboxes[growth].x;
			box.height = hitboxes[growth].y;
			return box;
		}
		
		override public function damage(enemy:GameSprite) : void
		{
			growth--;
			play(growth.toString());
			// Do some explosion or something
		}
		
		public function spawnSecretSeed() : void
		{
			var seed:Seed = new Seed(x + secretOffset.x, y + secretOffset.y);
			seed.secret = true;
			PlayState.instance.objects.add(seed);
		}
		
	}
	
}