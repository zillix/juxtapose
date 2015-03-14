package 
{
	
	/**
	 * ...
	 * @author zillix
	 */
	public class PlayText 
	{
		public static const DEFAULT_DURATION:Number = 2;
		public static const DEFAULT_TEXT_COLOR:uint = 0xffffff;
		public var text:String;
		public var duration:Number;
		public var callback:Function;
		public var color:uint = DEFAULT_TEXT_COLOR;
		
		public function PlayText(Text:String = "", Duration:Number = 0, Callback:Function = null, Color:uint = DEFAULT_TEXT_COLOR)
		{
			text = Text;
			duration = Duration;
			callback = Callback;
			color = Color;
		}
		
	}
	
}