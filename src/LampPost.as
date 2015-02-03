package 
{
		import org.flixel.*;
	/**
	 * ...
	 * @author zillix
	 */
	public class LampPost extends OrbHolder 
	{
		[Embed(source = "data/lamppost.png")]	public var LampPostSprite:Class;
		public static const LAMPPOST_NAME:String = "pillar";
		
		public var hidingNpcs:Vector.<NPC> = new Vector.<NPC>();
		
		public function LampPost(X:Number, Y:Number, S:int)
		{
			super(X, Y, S, 1, 78);
			loadGraphic(LampPostSprite);
			
			//addOrb(new Orb(x, y));
		}
		
		public function hideLock(npc:NPC) : void
		{
			hidingNpcs.push(npc);
		}
		
		public function hideUnlock(npc:NPC) : void
		{
			if (hidingNpcs.indexOf(npc) > -1)
			{
				hidingNpcs.splice(hidingNpcs.indexOf(npc), 1);
			}
		}
		
		
		override public function getExamineText() : Vector.<PlayText>
		{
			var text:Vector.<PlayText> = new Vector.<PlayText>();
			var day:int = PlayState.instance.day;
			
			addText(text, "a " + LAMPPOST_NAME);
			addText(text, "it can hold " + Orb.ORB_ARTICLE + " " + Orb.ORB_NAME);
			
			return text;
		}
		
		
	}
	
}