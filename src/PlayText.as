package 
{
	
	/**
	 * ...
	 * @author zillix
	 */
	public class PlayText 
	{
		public static const DEFAULT_DURATION:Number = 2;
		public var text:String;
		public var duration:Number;
		public var callback:Function;
		
		public function PlayText(Text:String = "", Duration:Number = 0, Callback:Function = null)
		{
			text = Text;
			duration = Duration;
			callback = Callback;
		}
		
	}
	
}