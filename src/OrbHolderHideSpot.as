package 
{
	
	/**
	 * ...
	 * @author zillix
	 */
	public class OrbHolderHideSpot extends OrbHolder 
	{
		public var hidingNpcs:Vector.<NPC> = new Vector.<NPC>();
		
		
		public function OrbHolderHideSpot(X:Number, Y:Number, state:int, max:int = 1, oHeight:int = 0)
		{
			super(X, Y, state, max, oHeight);
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
	}
	
}