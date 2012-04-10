package nl.techtribe.logx
{
	import flash.utils.getTimer;
	import nl.techtribe.logx.vo.VOLogLevel;
	import nl.techtribe.logx.vo.VOLogMessage;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.system.System;

	/**
	 * Log, a small but powerful tool for logging statements, objects and properties.
	 * When using Eclipse you can combine it with plugins like "grep_console" (google it) to colorize your console for better insight.
	 *  
	 * @author Joey van Dijk
	 * @see http://www.techtribe.nl
	 */
	public class Log
	{
		public static const INFO:int = 0;
		public static const DEBUG:int = 1;
		public static const WARNING:int = 2;
		public static const ERROR:int = 3;

		private static var _stage:Stage;
		private static var _remoteConnection:Remote;
		private static var _remote:Boolean = false;
		private static var _remoteID:String;
		private static var _remoteReady:Boolean = false;
		private static var _waitMessages:Vector.<VOLogMessage> = new Vector.<VOLogMessage>();
		private static var _enabled:Boolean = true;
		private static var _restrictLevel:VOLogLevel = new VOLogLevel();
		
		public static var timestamp:Boolean = false;
		public static var ms:Boolean = false;
		public static var memory:Boolean = false;
		
		/**
		 * Logging function x(input:*) to trace all kinds of information.
		 * @param input <code>Object, String, Array, *</code> - to trace
		 * @param level <code>int</code> - of log level
		 * @param properties <code>Vector.&lt;int&gt;</code> - properties to show
		 * @default <code>INFO</code>
		 */
		public static function x(input:*,level:int = INFO,props:Vector.<String> = null):void
		{
			if(!enabled){return;}
			
			var s:String = '';
			//check disabled/restricted levels
			if(_restrictLevel.filter){
				if(!_restrictLevel.find(level)){
					return;
				}
			}			

			//check timestamp
			if(timestamp)
			{
				s += createTimestamp()+' - ';
			}

			//trace statement
			s += parse(input,props);

			//check memory
			if(memory)
			{
				s += ' ('+createMemory()+')'; 
			}
			
			//log
			send(s,level);
		}
		
		/**
		 * Provide the name of the log level.
		 * @param level <code>int</code> - the integer value of the Type, found at Log.INFO / Log.WARNING / Log.DEBUG / Log.ERROR
		 * @return <code>String</code> - String representation of the log level. 
		 */
		public static function logLevel(level:int):String
		{
			if(level == INFO){
				return 'INFO';
			}else if(level == DEBUG){
				return 'DEBUG';
			}else if(level == WARNING){
				return 'WARNING';
			}else if(level == ERROR){
				return 'ERROR';
			}else{
				return 'UNKNOWN';
			}
		}
		
		/**
		 * Show the children of the Stage or a specific Point at the stage.
		 * @param stage <code>Stage</code> - reference of the Stage
		 * @param point <code>Point</code> - on stage
		 * @default <code>null</code> - if default the stage children are shown, otherwise only below a certain point
		 */
		public static function children(pnt:Point = null):void
		{
			if(_stage == null)
			{
				x('Log.children() needs a Stage reference, so define "Log.stage = this.stage;" before using this method.',ERROR);
				return;
			}

			x('## Children:',INFO);
			if(pnt == null){
				//stage children are shown
				walkThrough(_stage);
			}else{
				//show children below a certain point
				getDepth(_stage.getObjectsUnderPoint(pnt),pnt,_stage.areInaccessibleObjectsUnderPoint(pnt));
			}
		}
		
		/**
		 * Restrict logging by defining which levels are skipped.
		 * @param level(s) <code>int / Array / Vector.&lt;int&gt; / Vector.&lt;uint&gt;</code> - which levels are skipped to trace
		 * @default <code>null</code>
		 * @exampleText Test <p>
		 * <code>
		 * 	Log.skip(); //all levels accepted
		 * </code>
		 * </p>
		 */
		public static function skip(level:* = null):void
		{
			if(!enabled){return;}

			if(level == null){
				//all levels are accepted
				_restrictLevel.reset();
			}else if(level is int){				
				_restrictLevel.skip(int(level));
			}else if(level is Array || level is Vector.<int> || level is Vector.<uint>){
				try{
					_restrictLevel.multiSkip(Vector.<int>(level));
				}catch(e:Error){
					x('Log.skip() needs an Array or Vector filled with only integers (int/uint) to compile.',ERROR);
					return;
				}
			}else{
				x('Log.skip() needs an Array/Vector/int to compile, but a '+level+' is now provided.',ERROR);
			}
		}
		
		/**
		 * Restrict logging by defining which levels are accepted.
		 * @param level(s) <code>int / Array / Vector.&lt;int&gt; / Vector.&lt;uint&gt;</code> - which levels are accepted to trace
		 * @default <code>null</code>
		 * @exampleText Test <p>
		 * <code>
		 * 	Log.restrict(); //all levels accepted
		 * </code>
		 * </p>
		 */
		public static function restrict(level:* = null):void
		{
			if(!enabled){return;}
			
			if(level == null){
				//all levels are accepted
				_restrictLevel.reset();
			}else if(level is int){				
				_restrictLevel.restrict(int(level));
			}else if(level is Array || level is Vector.<int> || level is Vector.<uint>){
				try{
					_restrictLevel.multiRestrict(Vector.<int>(level));
				}catch(e:Error){
					x('Log.restrict() needs an Array or Vector filled with only integers (int/uint) to compile.',ERROR);
					return;
				}
			}else{
				x('Log.restrict() needs an Array/Vector/int to compile, but a '+level+' is now provided.',ERROR);
			}
		}
		
		/**
		 * Logging function error(input:*) to trace all kinds of error information.
		 * @param input <code>Object, String, Array, *</code> - to trace
		 * @param properties <code>Vector.&lt;int&gt;</code> - properties to show
		 * @default <code>ERROR</code>
		 */
		public static function error(input:*,props:Vector.<String> = null):void
		{
			//alternative way of referencing LogX in your code
			Log.x(input,Log.ERROR,props);
		}
		
		/**
		 * Logging function info(input:*) to trace all kinds of info information.
		 * @param input <code>Object, String, Array, *</code> - to trace
		 * @param properties <code>Vector.&lt;int&gt;</code> - properties to show
		 * @default <code>INFO</code>
		 */
		public static function info(input:*,props:Vector.<String> = null):void
		{
			//alternative way of referencing LogX in your code
			Log.x(input,Log.INFO,props);
		}
		
		/**
		 * Logging function debug(input:*) to trace all kinds of debug information.
		 * @param input <code>Object, String, Array, *</code> - to trace
		 * @param properties <code>Vector.&lt;int&gt;</code> - properties to show
		 * @default <code>DEBUG</code>
		 */
		public static function debug(input:*,props:Vector.<String> = null):void
		{
			//alternative way of referencing LogX in your code
			Log.x(input,Log.DEBUG,props);
		}
		
		/**
		 * Logging function warning(input:*) to trace all kinds of warning information.
		 * @param input <code>Object, String, Array, *</code> - to trace
		 * @param properties <code>Vector.&lt;int&gt;</code> - properties to show
		 * @default <code>WARNING</code>
		 */
		public static function warning(input:*,props:Vector.<String> = null):void
		{
			//alternative way of referencing LogX in your code
			Log.x(input,Log.WARNING,props);
		}
		
		
		
		/////////////////// GETTER/SETTER FUNCTIONS /////////////////
		


		/**
		 * Retrieve current active levels.
		 * @return <code>Vector.&lt;int&gt;</code> - active levels as integers
		 */
		public static function get levels():Vector.<int>
		{
			return _restrictLevel.list();
		}
		
		/**
		 * Retrieve if remote logging is enabled.
		 * @return <code>Boolean</code> - remote logging is enabled/disabled
		 */
		public static function get remote():Boolean
		{
			return _remote;
		}
		
		/**
		 * Set remote logging enabled/disabled.
		 * @param input <code>Boolean</code> - remote logging is enabled/disabled
		 */
		public static function set remote(input:Boolean):void
		{
			if(input != _remote)
			{
				if(!enabled){return;}
				
				//validate if identifier is being set
				if(_remoteID == null)
				{
					throw new Error('LogX: Please provide a remoteID and use only 0-9, A-Z, a-z,".",~,_,-,/,\ characters, like for example "tld.companyname.projectname.ID8".');
				}
				
				//startup or stop rtmfp item
				_remote = input;
				
				if(_remote){
					_remoteConnection = new Remote(_remoteID);
					_remoteConnection.addEventListener(Remote.EVENT_READY, remoteReady);
				}else{
					_remoteConnection.removeEventListener(Remote.EVENT_READY, remoteReady);
					_remoteConnection.dispose();
					_remoteConnection = null;
					_waitMessages.splice(0,_waitMessages.length);
					_remoteReady = false;
				}
			}
		}

		/**
		 * Retrieve remote ID to connect to.
		 * @return <code>String</code> - remote ID that is used as a group identifier.
		 */
		public static function get remoteID() : String
		{
			return _remoteID;
		}

		/**
		 * Set remote ID enabled/disabled.
		 * @param input <code>String</code> - remote ID to use a group identifier.
		 */
		public static function set remoteID(input : String) : void
		{
			var loggerIdCheck:RegExp = /^[0-9a-zA-Z@\_\-\.\~\/\\]+$/i;
			if(loggerIdCheck.test(input)){
				_remoteID = input;
			}else{
				throw new Error('LogX: The provided remoteID is invalid, please use only 0-9, A-Z, a-z,".",~,_,-,/,\ characters like for example "tld.companyname.projectname.ID8".');
			}
		}
		
		/**
		 * Retrieve if logging is enabled.
		 * @return <code>Boolean</code> - logging is enabled/disabled
		 */
		public static function get enabled():Boolean
		{
			return _enabled;
		}
		
		/**
		 * Set logging enabled/disabled.
		 * @param input <code>Boolean</code> - logging is enabled/disabled
		 */
		public static function set enabled(input:Boolean):void
		{	
			if(input != _enabled)
			{
				if(!input)
				{
					//stop rtmfp because logging will be disabled in a moment.
					remote = false;
				}
				_enabled = input;
			}
		}
		
		/**
		 * Set stage for further logging capabilities.
		 * No getter is provided while stage reference is not ment to use throughout your application.
		 * @param input <code>Stage</code> - Stage reference to use.
		 */
		public static function set stage(stage : Stage) : void
		{
			_stage = stage;
		}
		
		
		
		
		/////////////////// PRIVATE FUNCTIONS /////////////////
		
		
		private static function remoteReady(event : Event) : void
		{
			_remoteReady = true;
			//paste all captured messages
			if(_remoteConnection){
				for each(var vo:VOLogMessage in _waitMessages)
				{
					send(vo.msg,vo.level);
				}				
				_waitMessages.splice(0,_waitMessages.length);
			}else{
				trace(logLevel(WARNING)+'	The RTMFP/P2P connection has been terminated unexpectedly.');
			}
		}		
		
		private static function shortenNumber(input:Number,no:int):String
		{
			var s:String = String(input);
			if(s.indexOf('.') != -1){
				return s.substr(0,s.indexOf('.')+no+1);
			}else{
				return s;
			}
		}
		
		private static function createMemory():String
		{
			var s:int = System.totalMemory;
			if(s < 1000){
				return shortenNumber(s,0)+' bytes ';
			}else if(s < 1000000){
				return shortenNumber(s*0.001,2)+' kB';
			}else if(s < 1000000000){
				return shortenNumber(s*0.000001,2)+' MB';
			}
			return '0 bytes';
		}
		
		private static function createTime(i:int,decimals:int = 2):String
		{
			if(i < 10 && decimals <= 2){
				return '0'+String(i);
			}else if(i < 10 && decimals == 3){
				return '00'+String(i);
			}else if(i < 100 && decimals == 3){
				return '0'+String(i);
			}else{
				return String(i);
			}
		}
		
		private static function createTimestamp():String
		{
			if(ms)
			{
				return String(getTimer());
			}
			var d:Date = new Date();
			var s:String = '';
			s += createTime(d.getHours())+':';
			s += createTime(d.getMinutes())+':';
			s += createTime(d.getSeconds())+'::';
			s += createTime(d.getMilliseconds(),3);
			return s;
		}		
		
		private static function getDepth(objects:Array,pnt:Point,omitted:Boolean):void
		{
			if(objects.length == 0){
				x('Log.children(Point) did not find any children at '+pnt+'.',INFO);
			}else{
				var i:int = 0;
				var il:int = objects.length;
				while(i < il)
				{
					var item:* = objects[i];
					if(omitted){
						x(i+' '+item+' "'+DisplayObject(item).name+'" inside '+DisplayObject(item).parent+' "'+DisplayObject(DisplayObject(item).parent).name+'" with inaccessible objects',INFO);
					}else{
						x(i+' '+item+' "'+DisplayObject(item).name+'" inside '+DisplayObject(item).parent+' "'+DisplayObject(DisplayObject(item).parent).name+'"',INFO);
					}
					i++;
				}
			}
		}
		
		private static function walkThrough(container:DisplayObjectContainer,levels:int = 0):void
		{
			//create indent
			var pre:String = '';
			var i:int = levels;
			while(i--)
			{
				pre += '	';
			}
			
			//walk through
			i = 0;
			var il:int = container.numChildren;
			while(i < il)
			{
				var dobj:* = container.getChildAt(i);
				if(dobj is DisplayObjectContainer){
					x(pre+i+' '+dobj+' - "'+DisplayObject(dobj).name+'"',INFO);
					walkThrough(dobj,levels+1);
				}else{
					x(pre+i+' '+dobj+' - "'+DisplayObject(dobj).name+'"',INFO);
				}
				i++;
			}
		}
		
		private static function parse(input:*,props:Vector.<String>):String
		{
			if(props == null){
				if(input is DisplayObject){
					return input+' "'+DisplayObject(input).name+'"';
				}else{
					return input;
				}
			}else{
				//detect properties
				var s:String;
				if(input is DisplayObject){
					s = input+' "'+DisplayObject(input).name+'" properties="';
				}else{
					s = input+' properties="';
				}

				var i:int = 0;
				var il:int = props.length;
				if(il > 0){
					while(i<il)
					{
						s += props[i]+':'+input[props[i]]+', ';
						i++;
					}
					s = s.substr(0,s.length-2)+'"';
				}else{
					s = s.substr(0,s.length-12)+'';
				}
				
				return s;
			}
		}
		
		private static function send(input:String,level:int):void
		{
			if(remote){
				//check if messages need to be stored
				if(remote && !_remoteReady)
				{
					var vo:VOLogMessage = new VOLogMessage();
					vo.msg = input;
					vo.level = level;
					
					_waitMessages.push(vo);
				}
			
				//send through rtmfp
				if(_remoteConnection)
				{
					if(!_remoteConnection.ready && _enabled){
						input = logLevel(WARNING)+'	Remote logging is not yet connected, so the message is skipped: '+input;
						trace(input);
					}else if(_enabled){
						_remoteConnection.send(input,level);
					}
				}
			}else{
				//check which level to add
				input = logLevel(level)+'	'+input;
				trace(input);
			}
		}		
	}
}