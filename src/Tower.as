package 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Tower extends OrbHolder 
	{
		[Embed(source = "data/towerSmall4.png")]	public var TowerSprite:Class;
		
		public static const STARTING_ORBS:int = 4;
		public static const SECRET_ORBS:int = 4;
		
		public static const ORB_Y_OFFSET:int = 20;
		public static const ORB_Y_SPACING:Number = 24.5;
		
		public var fakeOrbs:Vector.<FlxSprite> = new Vector.<FlxSprite>();
		public function Tower(X:Number, Y:Number) : void
		{
			super(X, Y, World.BOTH);
			loadGraphic(TowerSprite);
			scale.x = scale.y = 2;
			offset.x = width / 2;
			offset.y = height / 2;
		}
		
		public function initialize() : void
		{
			maxOrbs = PlayState.instance.countEndings >= (PlayState.MAX_ENDINGS - 1) ? SECRET_ORBS : STARTING_ORBS;
			for (var i:int = 0; i < maxOrbs; i++)
			{
				addOrb(new Orb(x, y - height * scale.y / 2 + ORB_Y_OFFSET + i * ORB_Y_SPACING));
			}
		}
		
		
		
		override protected function arrangeOrbs() : void
		{
			for (var i:int = 0; i < orbs.length; i++)
			{
				
				var realOrb:Orb = orbs[i];
				
				var orb:FlxSprite = fakeOrbs[i];
				orb.postUpdate();
				orb.x = x;
				var orbY:Number;
				if (PlayState.instance.state == World.LIGHT)
				{	
					orbY =  y - height * scale.y / 2 + ORB_Y_OFFSET + i * ORB_Y_SPACING;
					if (orb.y > orbY)
					{
						orb.acceleration.y = -World.GRAVITY * 2;
					}
					if (orb.y + orb.velocity.y * FlxG.elapsed < orbY)
					{
						orb.acceleration.y = 0;
						orb.velocity.y = 0;
						orb.y = orbY;
					}
				}
				else
				{
					orbY =  y + height * scale.y / 2 - ( ORB_Y_OFFSET + (orbs.length - i - 1) * ORB_Y_SPACING);
					if (orb.y < orbY)
					{
						orb.acceleration.y = World.GRAVITY * 2;
					}
					if (orb.y + orb.velocity.y * FlxG.elapsed > orbY)
					{
						orb.acceleration.y = 0;
						orb.velocity.y = 0;
						orb.y = orbY;
					}
				}
				
				realOrb.targetPoint = new FlxPoint(orb.x, orb.y);
			}
		}
		
		override public function get canExamine() : Boolean
		{
			return false;
		}
		
		override public function getExamineText() : Vector.<PlayText>
		{
			var text:Vector.<PlayText> = new Vector.<PlayText>();
			var orbCount:int = PlayState.instance.getOrbCount(state);
			var day:int = PlayState.instance.day;
			
			addText(text, "a spire. it is depleted of orbs");
			
			return text;
		}
		
		override public function addOrb(orb:Orb) : Boolean
		{
			if (!canPlaceOrb)
			{
				return false;
			}
			
			if (!initializing)
			{
				playPlacementSound();
			}
			
			orb.holder = this;
			
			if (orb.carried)
			{
				PlayState.instance.foregroundOrbs.remove(orb);
			}
			
			if (PlayState.instance.state == World.DARK)
			{
				orbs.splice(0, 0, orb);
			}
			else
			{
				orbs.push(orb);
			}
			orb.placed = true;
			PlayState.instance.backgroundOrbs.add(orb);
			
			
			if (fakeOrbs.length < orbs.length)
			{
				fakeOrbs.push(new FlxSprite(orb.x, orb.y));
			}
			arrangeOrbs();
			return true;
		}
		
		
	}
	
}