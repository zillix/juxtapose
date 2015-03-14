package 
{
	import org.flixel.*;
	/**
	 * ...
	 * @author zillix
	 */
	public class TextPlayer 
	{
		public var textQueue:Vector.<PlayText> = new Vector.<PlayText>();
		
		private var _currentText:String = "";
		private var _currentDuration:Number = 0;
		private var _currentCallback:Function = null;
		private var _currentColor:uint = PlayText.DEFAULT_TEXT_COLOR;
		
		public function TextPlayer()
		{
			
		}
		
		public function queue(text:Vector.<PlayText>) : void
		{
			textQueue = textQueue.concat(text);
		}
		
		public function playNow(text:Vector.<PlayText>) : void
		{
			if (!text || text.length == 0)
			{
				return;
			}
			
			textQueue = text.concat(textQueue);
			advanceText();
		}
		
		public function update() : void
		{
			if (_currentDuration > 0)
			{
				_currentDuration -= FlxG.elapsed;
				if (_currentDuration <= 0)
				{
					advanceText();
				}
			}
			else if (textQueue.length > 0)
			{
				advanceText();
			}
		}
		
		public function advanceText() : void
		{
			if (_currentCallback != null)
			{
				_currentCallback();		
			}
			
			if (textQueue.length > 0)
			{
				var next:PlayText = textQueue.splice(0, 1)[0];
				_currentText = next.text;
				_currentDuration = next.duration;
				_currentCallback = next.callback;
				_currentColor = next.color;
				
			}
			else
			{
				reset();
			}
		}
		
		public function reset() : void
		{
			_currentText = "";
			_currentDuration = 0;
			_currentCallback = null;
			_currentColor = PlayText.DEFAULT_TEXT_COLOR;
		}
		
		public function get currentText() : String
		{
			return _currentText;
		}
		
		public function get currentColor() : uint
		{
			return _currentColor;
		}
		
		public function get isBusy() : Boolean
		{
			return textQueue.length > 0 || _currentDuration > 0;
		}
		
	}
	
}