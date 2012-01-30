package nl.techtribe.logx.vo
{
	/**
	 * @author joeyvandijk
	 */
	public class VOLogMessage extends Object
	{
		public var id:int;
		public var msg:String;
		public var level:int;
		public var peer:String;
		
		//TODO v2: http://krisrok.de/blok/?p=57 rtmfp more info = speedier?
		public function VOLogMessage(){}
	}
}