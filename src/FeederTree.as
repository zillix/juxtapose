package 
{
	import flash.geom.Rectangle;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class FeederTree extends OrbHolder 
	{
		[Embed(source = "data/feederTreeSmall3.png")]	public var FeederTreeSprite:Class;
		[Embed(source = "data/statue.mp3")]	public var StatueSound:Class;
		
		public static const MAX_SEEDS:int = 1;
		public static const BONUS_SEEDS:int = 5;
		public var ORB_OFFSET:int = 41;
		public var seedsSpawned:int = 0;
		public var orbsEaten:int = 0;
		
		public function FeederTree(X:Number, Y:Number)
		{
			super(X, Y,World.LIGHT, 102);
			loadGraphic(FeederTreeSprite, true);
			addAnimation("idle0", [0]);
			addAnimation("idle1", [1]);
			addAnimation("idle2", [2]);
			addAnimation("idle3", [3]);
			addAnimation("idle4", [4]);
			play("idle0");
			offset.x = 0;
			orbHeight = 86;
			scale.x = scale.y = 2;
			offset.x = -width / 2;
			offset.y = height * 3 / 2;
			
		}
		
		override public function playPlacementSound() : void
		{
			FlxG.play(StatueSound, PlayState.SFX_VOLUME);
		}
		
		override public function addOrb(orb:Orb) : Boolean
		{
			var bool:Boolean = super.addOrb(orb);
			if (bool)
			{
				orb.consume();
				orbsEaten++;
			}
			
			return bool;
		}
		
		override public function get canTakeOrb() : Boolean
		{
			return false;
		}
		
		override public function update() : void
		{
			super.update();
			if (orbs.length > 0)
			{
				if (!orbs[0].alive)
				{
					orbs.length = 0;
					
					play("idle" + orbsEaten);
					if (seedsSpawned < MAX_SEEDS)
					{
						PlayState.instance.spawnSeed(seedsSpawned);
					}
					seedsSpawned++;
					if (seedsSpawned >= BONUS_SEEDS)
					{
						doBonus();
					}
				}
			}
		}
		
		public function doBonus(): void
		{
			
		}
		
		override protected function arrangeOrbs() : void
		{
			for (var i:int = 0; i < orbs.length; i++)
			{
				var realOrb:Orb = orbs[i];
				var orb:FlxPoint = orbPoints[i];
				orb.x = x + ORB_OFFSET;
				orb.y = y + (state == World.LIGHT ? -orbHeight : orbHeight);
				realOrb.targetPoint = orb;
			}
		}
		
		override public function getHitbox() : Rectangle
		{
			var bounds:Rectangle = super.getHitbox();
			bounds.width -= 50;
			return bounds;
		}
		
		override public function getExamineText() : Vector.<PlayText>
		{
			var text:Vector.<PlayText> = new Vector.<PlayText>();
			var orbCount:int = PlayState.instance.getOrbCount(state);
			var day:int = PlayState.instance.day;
			
			switch (seedsSpawned)
			{
				case 0:
					addText(text, "a disturbing statue");
					addText(text, "it looks like something would fit in its mouth");
					break;
					
				case 1:
					addText(text, "a strange statue");
					break;
					
				case 2:
					addText(text, "an elegant statue. it looks like it wants more orbs.");
					break;
					
				case 3:
					addText(text, "a sublime statue");
					break;
			}
			
			return text;
		}
		
		override public function get canActivate() : Boolean 
		{
			if (PlayState.instance.isEligibleForWorshipEnd)
			{
				return true;
			}
			
			return false;
		}
		
		override public function activate() : void { PlayState.instance.onWorship(); }
		
		override public function get activateString() : String { return "worship"; }
		
	}
	
}