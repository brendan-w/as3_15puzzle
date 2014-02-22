//Brendan Whitfield
package code
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent
	
	public class Data
	{
		private var manager:Main;
		private var urlLoader:URLLoader;
		public var picNames:Array; //data array
		
		public function Data(mgr:Main)
		{
			// constructor code
			manager = mgr;
			urlLoader = new URLLoader();
			picNames = new Array();
		}
		
		//start loading data
		public function loadData(fileName:String):void
		{
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			urlLoader.load(new URLRequest(fileName));
		}
		
		//when finished, parse and tell the manager to start everything
		private function onComplete(e:Event):void
		{
			urlLoader.removeEventListener(Event.COMPLETE, onComplete);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			picNames = String(urlLoader.data).split('\n');
			manager.init();
		}
		
		//just in case...
		private function onError(e:IOErrorEvent):void
		{
			trace("IO Error occurred");
		}
	}
}