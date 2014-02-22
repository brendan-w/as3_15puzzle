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
	import flash.display.MovieClip;
	
	public class Solver
	{
		//readouts
		private var bar1:MovieClip;
		private var bar2:MovieClip;
		//when false, timer fires will not spawn more iterations
		public var ready:Boolean;
		//root node
		private var rootNode:Node;
		//hash table of all nodes
		private var hashTable:Array;
		//table of all fringe nodes (sorted HighR to LowR)
		private var fringe:Array;
		//holds the node with a finished puzzle
		private var finished:Node;
		//constants
		public const cols:int = 4;
		public const rows:int = 4;
		public const maxHash:int = 100000;

		public function Solver(dataHandler:Data, puzzle:Puzzle, b1:MovieClip, b2:MovieClip)
		{
			// constructor code
			ready = false;
			bar1 = b1;
			bar2 = b2;
			finished = null;
			fringe = new Array();
			hashTable = new Array();
			//make 2nd dimension of hash table
			for(var e:int = 0; e < maxHash; e++)
			{
				hashTable[e] = new Array();
			}
			//make the new root node
			rootNode = new Node(this, null, -1, -1);
			rootNode.blankTile = puzzle.getBlank();
			//fill the tiles array
			var current:Array = puzzle.getTiles();
			for(var i:int = 0; i < current.length; i++)
			{
				rootNode.tiles[i] = dataHandler.picNames.indexOf(current[i].getFrame());
			}
			//initialize the root node
			rootNode.getStats();
			addNode(rootNode);
			fringe.push(rootNode);
			ready = true;
		}
		
		//expand 1 node, and return any solutions
		public function solve(display:Boolean = false):Array
		{
			ready = false;
			//pick the fringe node with the lowest rating
			var node:Node = fringe.pop();
			//expand the node
			var newNodes:Array = node.expand();
			//remove new nodes that have colliding puzzles
			removeCollisions(newNodes);
			//add the new nodes to the master list and the fringe list
			for(var e:int = 0; e < newNodes.length; e++)
			{
				addNode(newNodes[e]);
				addFringe(newNodes[e]);
			}
			//update the progress bar
			if(display)
			{
				bar1.gotoAndStop(int((node.manhattan - rootNode.manhattan) * (101 - 1) / (0 - rootNode.manhattan) + 1));
				if(bar1.currentFrame > bar2.currentFrame) bar2.gotoAndStop(bar1.currentFrame);
			}
			ready = true;
			return getSolution();
		}
		
		//a node reports being solved
		public function solved(node:Node):void
		{
			finished = node;
		}
		
		//support functions//////////////////////////////////////////////////
		
		private function getSolution():Array
		{
			var solution:Array = null;
			if(finished != null)
			{
				solution = new Array();
				//follow the node tree back to the root
				var current:Node = finished;
				while(current != rootNode)
				{
					solution.push(current.thisMove);
					current = current.origin;
				}
			}
			return solution;
		}

		//binary insertion of nodes in the fringe list (keeps it sorted)
		private function addFringe(node:Node):void
		{
			var left:int = 0;
			var right:int = fringe.length - 1;
			if(right > -1)
			{
				while(left < right)
				{
					var middle:int = Math.floor((left + right) / 2);
					if(node.rating >= fringe[middle].rating)
					{
						right = middle;
					}
					else
					{
						left = middle + 1;
					}
				}
				if(node.rating > fringe[left].rating)
				{
					fringe.splice(left, 0, node);
				}
				else
				{
					fringe.splice(left + 1, 0, node);
				}
			}
			else
			{
				fringe.push(node);
			}
		}
		
		//add node to the hashtable based on its puzzle hash
		private function addNode(node:Node):void
		{
			hashTable[node.hash].push(node);
		}
		
		//remove nodes that have duplicates puzzles
		private function removeCollisions(nodeArray:Array):void
		{
			for(var i:int = 0; i < nodeArray.length; i++)
			{
				if(collision(nodeArray[i]))
				{
					nodeArray.splice(i,1);
				}
			}
		}
		
		//see if a given node has the same puzzle as one previously generated
		private function collision(node:Node):Boolean
		{
			//get the corresponding hash array
			var array:Array = hashTable[node.hash];
			//test its elemenets for collisions
			var i:int = 0;
			var found:Boolean = false;
			while(!found && (i < array.length))
			{
				if(puzzleMatch(node, array[i]))
				{
					found = true;
				}
				i++;
			}
			return found;
		}
		
		//checks if the puzzles of two nodes are equal
		private function puzzleMatch(node1:Node, node2:Node):Boolean
		{
			var i:int = 0;
			var match:Boolean = true;
			while(match && (i < node1.tiles.length))
			{
				if(node1.tiles[i] != node2.tiles[i]) match = false;
				i++;
			}
			return match;
		}
	}
}