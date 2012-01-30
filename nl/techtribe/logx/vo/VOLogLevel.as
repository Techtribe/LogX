package nl.techtribe.logx.vo
{
	import nl.techtribe.logx.Log;
	/**
	 * @author joeyvandijk
	 */
	public class VOLogLevel
	{
		public var filter:Boolean = false;

		public var info:Boolean = false;
		public var debug:Boolean = false;
		public var warning:Boolean = false;
		public var error:Boolean = false;
		
		public function list():Vector.<int>
		{
			var l:Vector.<int> = new Vector.<int>();
			if(info){
				l.push(Log.INFO);
			}else if(debug){
				l.push(Log.DEBUG);
			}else if(warning){
				l.push(Log.WARNING);
			}else if(error){
				l.push(Log.ERROR);
			}
			return l;
		}
		
		public function find(level:int):Boolean
		{
			if(level == Log.INFO){
				return info;
			}else if(level == Log.DEBUG){
				return debug;
			}else if(level == Log.WARNING){
				return warning;
			}else if(level == Log.ERROR){
				return error;
			}
			return false;
		}
		
		public function checkFiltered():void
		{
			if(info == false && debug == false && warning == false && error == false)
			{
				filter = false;
			}
		}
		
		public function multiSkip(levels:Vector.<int>):void
		{
			for each(var l:int in levels)
			{
				skip(l);
			}
		}
		
		public function skip(level:int):void
		{
			if(level == Log.INFO){
				info = false;
			}else if(level == Log.DEBUG){
				debug = false;
			}else if(level == Log.WARNING){
				warning = false;
			}else if(level == Log.ERROR){
				error = false;
			}
			checkFiltered();
		}
		
		public function multiRestrict(levels:Vector.<int>):void
		{
			for each(var l:int in levels)
			{
				restrict(l);
			}
		}
		
		public function restrict(level:int):void
		{
			if(level == Log.INFO){
				info = true;
			}else if(level == Log.DEBUG){
				debug = true;
			}else if(level == Log.WARNING){
				warning = true;
			}else if(level == Log.ERROR){
				error = true;
			}
			filter = true;
		}
		
		public function reset():void
		{
			info = debug = warning = error = filter = false;
		}
	}
}