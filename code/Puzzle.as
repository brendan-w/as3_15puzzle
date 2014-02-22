//Brendan Whitfield
package code
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Puzzle extends Sprite
	{
		private var dataHandler:Data;
		private var manager:Main;
		private var tiles:Array;
		private var blankTile:PuzzleTile;
		public var won:Boolean = false;
		private var gap:Number = 2;
		private var auto:Boolean = false; //auto mode empties the solution array by executing moves
		private var solution:Array;
		
		private const cols:int = 4;
		private const rows:int = 4;
		private const scale:Number = 1;
		private const constGap:Number = 2;
		private const accel:Number = 0.5;
		private const winAccel:Number = 0.2;
		private const tolerance:Number = 0.75;
		
		public function Puzzle(dat:Data, mgr:Main)
		{
			// constructor code
			dataHandler = dat;
			manager = mgr;
			tiles = new Array();
		}
		
		//create everything
		public function init():void
		{
			gap = constGap;
			for(var i:int = 0; i < dataHandler.picNames.length; i++)
			{
				var newTile:PuzzleTile = new PuzzleTile(dataHandler.picNames[i], this);
				tiles.push(newTile);
				addChild(newTile);
				//scale the tile
				newTile.width *= scale;
				newTile.height *= scale;
			}
			//remember the last tile (the "blank" space)
			blankTile = tiles[tiles.length - 1];
			blankTile.alpha = 0;
			//mix the tiles
			mixTiles();
			//align the tiles into a grid (non animated)
			alignTiles(false);
			//start the animator ticking
			addEventListener(Event.ENTER_FRAME, frameLoop);
		}
		
		//move a tile if the blank tile is next to it (called by PuzzleTile)
		public function tileClick(tile:PuzzleTile):void
		{
			if((tile != blankTile) && (!won) && (!auto))
			{
				//get the index of the clicked tile
				var index:int = tiles.indexOf(tile);
				var xPos:int = index % cols;
				var yPos:int = Math.floor(index / rows);
				
				//check all 4 directions for the blank tile
				if((xPos > 0) && (tiles[index - 1] == blankTile))
				{
					switchTile(index); //slide left
				}
				else if((xPos < (cols - 1)) && (tiles[index + 1] == blankTile))
				{
					switchTile(index); //slide right
				}
				else if((yPos > 0) && (tiles[index - cols] == blankTile))
				{
					switchTile(index); //slide up
				}
				else if((yPos < (rows - 1)) && (tiles[index + cols] == blankTile))
				{
					switchTile(index); //slide down
				}
			}
		}
		
		//function to switch the givin tile with the blank tile
		private function switchTile(index:int, winCheck:Boolean = true):void
		{
			var blankIndex:int = tiles.indexOf(blankTile);
			tiles[blankIndex] = tiles[index];
			tiles[index] = blankTile;
			if(winCheck) checkWin();
		}
		
		//see if the puzzle is finished
		private function checkWin():void
		{
			var i:int = 0;
			var winning:Boolean = true;
			while(winning && (i < tiles.length))
			{
				if(tiles[i].getFrame() != dataHandler.picNames[i]) winning = false;
				i++;
			}
			if(winning && !won)
			{
				won = true;
				manager.won();
			}
		}
		
		//update the position of each tile
		private function frameLoop(e:Event):void
		{
			alignTiles(true);
		}
		
		//function for positioning the tiles based on their position in the array
		private function alignTiles(animate:Boolean):void
		{
			var endX:int;
			var endY:int;
			var moving:Boolean = false;
			
			for(var i:int = 0; i < tiles.length; i++)
			{
				//calculate the ending X and Y positions
				endX = ((i % cols) * tiles[i].width) + (i % cols) * gap;
				endY = (Math.floor(i / rows) * tiles[i].height) + Math.floor(i / rows) * gap;
				
				if(animate) //animate the tile movement
				{
					var finX:Boolean = false;
					var finY:Boolean = false;
					//snap when within tolerance distance
					if(Math.abs(endX - tiles[i].x) <= tolerance)
					{
						tiles[i].x = endX;
					}
					else //tile needs more moving
					{
						tiles[i].x += (endX - tiles[i].x) * accel;
						moving = true;
					}
					
					//snap when within tolerance distance
					if(Math.abs(endY - tiles[i].y) <= tolerance)
					{
						tiles[i].y = endY;
					}
					else //tile needs more moving
					{
						tiles[i].y += (endY - tiles[i].y) * accel;
						moving = true;
					}
				}
				else //slam the tiles into place
				{
					tiles[i].x = endX;
					tiles[i].y = endY;
				}
			}
			
			//if winning conditions are achieved
			if(won)
			{
				//send everything to a win state
				if(blankTile.alpha < 1) blankTile.alpha += 0.04;
				if(gap > 0) gap -= 0.1;
				//move the whole puzzle to center
				endX = (stage.stageWidth / 2) - (this.width / 2);
				if(Math.abs(endX - this.x) <= tolerance)
				{
					this.x = endX;
				}
				else //tile needs more moving
				{
					this.x += (endX - this.x) * winAccel;
				}
				
			}
			//if the last move animation is complete, run the next move
			if(!moving && auto)
			{
				if(solution.length != 0)
				{
					var mov:int = solution.pop();
					//trace(mov);
					switchTile(mov);
				}
				else
				{
					auto = false;
				}
			}
		}
		
		//reset the puzzle
		public function resetMe():void
		{
			auto = false;
			solution = null;
			blankTile.alpha = 0;
			gap = constGap;
			mixTiles();
		}
		
		//mix the tiles
		private function mixTiles():void
		{
			var lastPos:int = -1;
			for(var i:int = 0; i < 35; i++)
			{
				var options:Array = getOptions();
				
				//remove the last position from consideration
				if(lastPos > -1)
				{
					options.splice(options.indexOf(lastPos), 1);
				}
				lastPos = tiles.indexOf(blankTile);
				
				var rand:int = Math.floor(Math.random() * options.length);
				//switch the tile
				switchTile(options[rand], false);
			}
			
		}
		
		//return array of the valid moves of the blank tile
		private function getOptions():Array
		{
			var blank:int = tiles.indexOf(blankTile);
			var answer:Array = new Array();
			var xPos:int = blank % cols;
			var yPos:int = Math.floor(blank / rows);
			if(xPos > 0)
			{
				answer.push(blank - 1);
			}
			if(xPos < (cols - 1))
			{
				answer.push(blank + 1);
			}
			if(yPos > 0)
			{
				answer.push(blank - cols);
			}
			if(yPos < (rows - 1))
			{
				answer.push(blank + cols);
			}
			return answer;
		}
		
		public function solve(solMoves:Array):void
		{
			solution = solMoves;
			//start the puzzle auto solving
			auto = true;
		}
		
		public function getTiles():Array
		{
			return tiles;
		}
		
		public function getBlank():int
		{
			return tiles.indexOf(blankTile);
		}
	}
}