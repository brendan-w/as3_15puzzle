//Brendan Whitfield
package code
{
	import flash.events.MouseEvent;

	public class PuzzleTile extends Tile
	{
		private var manager:Puzzle;

		public function PuzzleTile(frameLabel:String, mgr:Puzzle)
		{
			// constructor code
			super(frameLabel);
			manager = mgr;
			addEventListener(MouseEvent.CLICK, mClick);
		}
		
		//when clicked, report to the puzzle class for handling
		private function mClick(e:MouseEvent):void
		{
			manager.tileClick(this);
		}
	}
}