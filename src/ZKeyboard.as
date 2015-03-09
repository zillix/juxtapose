package 
{
	import flash.events.KeyboardEvent;
	import org.flixel.system.input.Keyboard;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class ZKeyboard extends Keyboard 
	{
		public var fullscreenCallback:Function = null;
		public var fullscreenName:String = null;
		override public function handleKeyDown(FlashEvent:KeyboardEvent):void
		{
			super.handleKeyDown(FlashEvent);
			
			var object:Object = _map[FlashEvent.keyCode];
			if (object == null) return;
			
			if (fullscreenCallback == null || fullscreenName == null)
			{
				return;
			}
			
			if (fullscreenName == object.name)
			{
				fullscreenCallback();
			}
		}
	}
	
}