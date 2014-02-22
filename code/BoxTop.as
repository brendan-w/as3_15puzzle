//Brendan Whitfield
package code
{
	import flash.display.Sprite;
	
	public class BoxTop extends Sprite
	{
		private var dataHandler:Data;
		private var tiles:Array;
		private const scale:Number = 0.5;
		
		public function BoxTop(dat:Data)
		{
			// constructor code
			dataHandler = dat;
			tiles = new Array();
		}
		
		//create boxtiles in a grid to form the finished image
		public function init():void
		{
			for(var i:int = 0; i < dataHandler.picNames.length; i++)
			{
				var newTile:BoxTile = new BoxTile(dataHandler.picNames[i]);
				tiles.push(newTile);
				addChild(newTile);
				//scale the tile before moving it in to place
				newTile.width *= scale;
				newTile.height *= scale;
				newTile.x = (i % 4) * newTile.width;
				newTile.y = Math.floor(i / 4) * newTile.height;
			}
		}
	}
}