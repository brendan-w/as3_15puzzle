/*
Written & Designed by: Brendan Whitfield
Date: 1-28-2013
Notes:
	The tools and techniques used in this project were learned in previous programming
	(and math) classes from high school.
	
	Other References:
		http://en.wikipedia.org/wiki/A*_search_algorithm
		https://ece.uwaterloo.ca/~dwharder/aads/Algorithms/N_puzzles/
*/
package code
{
	import code.Node;
	
	public class Node
	{
		private var manager:Solver; //Used for callback when a finished puzzle is found
		public var origin:Node; //parent node
		public var tiles:Array; //puzzle state
		public var blankTile:int; //index of the blank tile
		public var thisMove:int; //move that this tile represents
		//puzzle stats
		public var hash:int; //hashcode (used in checking for duplicates, prevents circular processing)
		public var manhattan:int; //distance from a solved puzzle (0 = solved)
		public var numMoves:int; //number of moves made (distance from root)
		public var rating:int; //heuristic
		
		public function Node(mgr:Solver, orig:Node, nextMove:int, prevMoves:int)
		{
			// constructor code
			manager = mgr;
			origin = orig;
			thisMove = nextMove;
			numMoves = 0;
			tiles = new Array();
			if(origin != null)
			{
				//get the tile arrangment from the parent node
				for(var i:int = 0; i < origin.tiles.length; i++)
				{
					tiles[i] = origin.tiles[i];
				}
				//get the blankTile
				blankTile = origin.blankTile;
				//update this node
				switchTile(thisMove);
				//update the stats for this node
				numMoves = prevMoves + 1;
				getStats();
			}
		}
		
		//function setting the hash and ratings for this node
		public function getStats():void
		{
			//get stats on this arrangment
			manhattan = manhattanDist();
			if(manhattan == 0)
			{
				//call manager when puzzle is solved
				manager.solved(this);
			}
			else
			{
				hash = getHash();
				//original rating equation:
				//rating = manhattan + numMoves;
				//custom ratings (closer puzzles more valuable, optimal path not important)
				rating = (manhattan * 2) + numMoves;
			}
		}
		
		//method returning an array of new descendant nodes (excluding the origin)
		public function expand():Array
		{
			//get the possible moves
			var options:Array = getOptions();
			//eliminate the origin node
			if(origin != null)
			{
				options.splice(options.indexOf(origin.blankTile), 1);
			}
			//create the new nodes
			var nodeArray:Array = new Array();
			for(var i:int = 0; i < options.length; i++)
			{
				nodeArray.push(new Node(manager, this, options[i], numMoves));
			}
			return nodeArray;
		}
		
		//return array of the valid moves of the blank tile
		private function getOptions():Array
		{
			var answer:Array = new Array();
			var xPos:int = blankTile % manager.cols;
			var yPos:int = Math.floor(blankTile / manager.rows);
			if(xPos > 0)
			{
				answer.push(blankTile - 1);
			}
			if(xPos < (manager.cols - 1))
			{
				answer.push(blankTile + 1);
			}
			if(yPos > 0)
			{
				answer.push(blankTile - manager.cols);
			}
			if(yPos < (manager.rows - 1))
			{
				answer.push(blankTile + manager.cols);
			}
			return answer;
		}
		
		//hash function returning the code for this puzzle arrangment
		private function getHash():int
		{
			var sum:int = 0;
			if(origin != null) sum = origin.hash;
			for(var i:int = 0; i < tiles.length; i++)
			{
				sum += Math.pow((i * tiles[i]), 2);
			}
			return (sum % manager.maxHash);
		}
		
		
		//get the distance of the puzzle from being solved
		private function manhattanDist():int
		{
			//sum the distance each tile needs to be moved
			var distance:int = 0;
			for(var i:int = 0; i < tiles.length; i++)
			{
				if(i != blankTile) distance += minDist(i);
			}
			return distance;
		}
		
		//get the minimum distance from the correct location
		private function minDist(i:int):int
		{
			var xPos:int = i % manager.cols;
			var yPos:int = Math.floor(i / manager.rows);
			var endXPos:int = tiles[i] % manager.cols;
			var endYPos:int = Math.floor(tiles[i] / manager.rows);
			return Math.abs(endXPos - xPos) + Math.abs(endYPos - yPos);
		}
		
		//function for switching a tile with the blanktile
		private function switchTile(index:int):void
		{
			var tile:int = tiles[index];
			tiles[index] = tiles[blankTile];
			tiles[blankTile] = tile;
			blankTile = index;
		}
	}
}