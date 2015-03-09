package 
{
		import org.flixel.*;
	/**
	 * ...
	 * @author zillix
	 */
	public class LampPost extends OrbHolderHideSpot 
	{
		[Embed(source = "data/lamppost.png")]	public var LampPostSprite:Class;
		public static const LAMPPOST_NAME:String = "pillar";
		public static const MAX_LAMP_POSTS:int = 2;
		
		public function LampPost(X:Number, Y:Number, S:int)
		{
			super(X, Y, S, 1, 78);
			loadGraphic(LampPostSprite);
			
			//addOrb(new Orb(x, y));
		}
		
		override public function getExamineText() : Vector.<PlayText>
		{
			var text:Vector.<PlayText> = new Vector.<PlayText>();
			var day:int = PlayState.instance.day;
			
			addText(text, "a " + LAMPPOST_NAME, 1.5);
			addText(text, "it can hold " + Orb.ORB_ARTICLE + " " + Orb.ORB_NAME);
			
			return text;
		}
		
		override public function addOrb(orb:Orb) : Boolean
		{
			var success:Boolean = super.addOrb(orb);
			if (success)
			{
				var orbBeam:OrbBeam = new OrbBeam(x, y, state);
				PlayState.instance.orbBeams.add(orbBeam);
			}
			
			return success;
			
		}
		
		
	}
	
}