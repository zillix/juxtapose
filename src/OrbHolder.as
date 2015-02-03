package 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class OrbHolder extends GameSprite 
	{
		[Embed(source = "data/placeOrb.mp3")]	public var PlaceOrbSound:Class;
			
		public var orbs:Vector.<Orb> = new Vector.<Orb>();
		public var orbPoints:Vector.<FlxPoint> = new Vector.<FlxPoint>();
		public var orbHeight:int = 0;
		public var maxOrbs:int = 1;
		public var bobAngle:Number = 0;
		public var initializing:Boolean = true;
		
		
		
		public function OrbHolder(X:Number, Y:Number, state:int, max:int = 1, oHeight:int = 0)
		{
			super(X, Y, state);
			maxOrbs = max;
			orbHeight = oHeight;
			bobAngle = Math.random() * 360;
		}
		
		public function get canPlaceOrb() : Boolean
		{
			return orbs.length < maxOrbs && !PlayState.instance.hasPendingEnding;
		}
		
		public function get canTakeOrb() : Boolean
		{
			return orbs.length > 0 && !PlayState.instance.hasPendingEnding;
		}
		
		public function playPlacementSound() : void
		{
			FlxG.play(PlaceOrbSound, PlayState.SFX_VOLUME);
		}
		
		public function addOrb(orb:Orb) : Boolean
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
			orbs.push(orb);
			orb.placed = true;
			PlayState.instance.backgroundOrbs.add(orb);
			
			if (orbPoints.length < orbs.length)
			{
				orbPoints.push(new FlxPoint(0, 0));
			}
			
			arrangeOrbs();
			return true;
		}
		
		public function removeOrb() : Orb
		{
			if (!canTakeOrb)
			{
				return null;
			}
			
			var orb:Orb;
			if (PlayState.instance.state == World.LIGHT)
			{
				orb = orbs.splice(0, 1)[0];
			}
			else
			{
				orb = orbs.splice(orbs.length - 1, 1)[0];
			}
			
			if (orb != null)
			{
				orb.holder = null;
				orb.placed = false;
				PlayState.instance.backgroundOrbs.remove(orb);
				PlayState.instance.foregroundOrbs.add(orb);
			}
			
			arrangeOrbs();
			return orb;
		}
		
		override public function update() : void
		{
			// TODO(ALEX): Orbs should fall fluidly
			arrangeOrbs();
			bobOrbs();
			initializing = false;
		}
		
		protected function arrangeOrbs() : void
		{
			for (var i:int = 0; i < orbs.length; i++)
			{
				var realOrb:Orb = orbs[i];
				var orb:FlxPoint = orbPoints[i];
				orb.x = x;
				orb.y = y + (state == World.LIGHT ? -orbHeight : orbHeight);
				
				realOrb.targetPoint = orb;
			}
		}
		
		protected function bobOrbs() : void
		{
			bobAngle += FlxG.elapsed * 90;
			for each (var orb:FlxPoint in orbPoints)
			{
				orb.y += Math.sin(PlayState.toRadians(bobAngle)) * 3;
			}
		}
		
		
		
		public function get canActivate() : Boolean { return false; }
		public function activate() : void { }
		
		public function get activateString() : String { return "activate"; }
		public function get placeString() : String { return "place"; }
	}
	
}