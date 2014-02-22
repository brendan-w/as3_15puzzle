//Brendan Whitfield
package code
{
	import flash.display.MovieClip;

	public class Tile extends MovieClip
	{
		public function Tile(frameLabel:String)
		{
			// constructor code
			gotoAndStop(frameLabel);
		}
		
		//set the frame using the frame label
		public function setFrame(frameLabel:String):void
		{
			gotoAndStop(frameLabel);
		}
		
		//return the label of the frame
		public function getFrame():String
		{
			return currentFrameLabel;
		}
	}
}