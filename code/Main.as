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
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	//timer
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	public class Main extends MovieClip
	{
		private var dataHandler:Data;
		private var puzzle:Puzzle;
		private var boxTop:BoxTop;
		
		//solver data
		private var solver:Solver;
		//timer is needed to prevent flash from timing out during a large process
		private var timer:Timer;
		private var working:Working;
		//dynamic throttling of the solver engine (iterations per time)
		private const time:int = 75;
		private const procTime:int = time - 15; //give 15 milliseconds back to flash
		private var iterate:int = 200; //default number of iterations to run

		public function Main()
		{
			// constructor code
			dataHandler = new Data(this);
			dataHandler.loadData("picNames.txt");
			resetBtn.addEventListener(MouseEvent.CLICK, reset);
			solveBtn.addEventListener(MouseEvent.CLICK, solve);
			timer = new Timer(time);
			timer.addEventListener(TimerEvent.TIMER, cycle);
		}
		
		//called by dataHandler upon load completion
		public function init():void
		{
			//create boxTop
			boxTop = new BoxTop(dataHandler);
			addChild(boxTop);
			boxTop.init();
			
			//create puzzle
			puzzle = new Puzzle(dataHandler, this);
			addChild(puzzle);
			puzzle.init();
			
			//position on screen
			var gap:Number = (stage.stageWidth - boxTop.width - puzzle.width) / 3;
			//center on the right side of the screen
			boxTop.x = puzzle.width + (gap * 2);
			boxTop.y = (stage.stageHeight - boxTop.height)/2;
			//center on the left side of the screen
			puzzle.x = gap;
			puzzle.y = (stage.stageHeight - puzzle.height)/2;
			
			//create processing animation
			working = new Working();
			addChild(working);
			//working.proc.y = 201;
			//working.proc.x = puzzle.x + ((puzzle.width - working.proc.width) / 2);
			working.visible = false;
		}
		
		//starts frameloop() running
		public function won():void
		{
			addEventListener(Event.ENTER_FRAME, frameLoop);
		}
		
		//frameloop runs after winning, dispenses confetti/money
		private function frameLoop(e:Event):void
		{
			//make confetti
			makeConfetti(3);
			if(boxTop.alpha > 0) boxTop.alpha -= 0.04;
		}
		
		//generate some confetti
		private function makeConfetti(pieces:int = 1):void
		{
			var newPiece:Confetti;
			for(var i:int = 0; i < pieces; i++)
			{
				//create a new piece
				newPiece = new Confetti(this);
				addChildAt(newPiece, 0);
				//move the piece for a random drop
				newPiece.x = Math.random() * stage.stageWidth;
				newPiece.y = -newPiece.height;
			}
		}
		
		//removal of confetti from the stage
		public function removeMe(piece:Confetti):void
		{
			removeChild(piece);
		}
		
		//reset button handler
		private function reset(e:MouseEvent):void
		{
			puzzle.resetMe()
			working.progressBar1.gotoAndStop(1);
			working.progressBar2.gotoAndStop(1);
			if(puzzle.won)
			{
				removeEventListener(Event.ENTER_FRAME, frameLoop);
				//center on the left side of the screen
				var gap:Number = (stage.stageWidth - boxTop.width - puzzle.width) / 3;
				puzzle.x = gap;
				puzzle.y = (stage.stageHeight - puzzle.height)/2;
				
				boxTop.alpha = 1;
				puzzle.won = false;
			}
		}
		
		//solve button
		private function solve(e:MouseEvent):void
		{
			working.visible = true;
			solver = new Solver(dataHandler, puzzle, working.progressBar1, working.progressBar2);
			timer.start();
		}
		
		//iteration routine for the solver (runs on every timer fire)
		public function cycle(e:TimerEvent):void
		{
			//cycle the solver
			if(solver.ready)
			{
				//capture the start time
				var s:Number = (new Date).getMilliseconds();
				//run iterations
				var solution:Array = null;
				var i:int = 0;
				while((solution == null) && (i < iterate))
				{
					//run 1 solve iteration, and update the display on the first iteration
					solution = solver.solve((i == 0));
					i++;
				}
				if(solution != null)
				{
					solver = null;
					timer.stop();
					working.visible = false;
					//trace(solution);
					puzzle.solve(solution);
				}
				//test the end time
				var total:int = ((new Date).getMilliseconds() - s);
				//update the display
				working.progressBar3.gotoAndStop(Math.floor((iterate - 1) * (101 - 1) / (500 - 1) + 1))
				//adjust the iteration time accordingly
				if(total > procTime)
				{
					if(iterate > 2) iterate -= 2;
				}
				else
				{
					iterate += 2;
				}
			}
		}
	}
}