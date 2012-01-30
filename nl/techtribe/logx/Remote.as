package nl.techtribe.logx
{
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.net.NetGroupReceiveMode;
	import flash.net.NetGroupSendMode;
	import flash.net.NetGroupSendResult;
	import flash.net.registerClassAlias;
	import nl.techtribe.logx.vo.VOLogMessage;

	/**
	 * @author joeyvandijk
	 */
	public class Remote
	{
		private var group : NetGroup;
		private var nc:NetConnection;
		private var _ready:Boolean = false;
		private var id:int = 0;
		private var groupAddress:String;
		private var peerID : String;
		private var neighbour : String;
		private var connectionWarningReported:Boolean = false;
		private var groupID:String = '';

		public function Remote(g:String):void
		{
			groupID = g;
			
			registerClassAlias('nl.techtribe.logx.vo.VOLogMessage', VOLogMessage);
			
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			nc.connect("rtmfp:");
		}
		
		private function netStatus(e:NetStatusEvent):void
		{
			switch(Object(e.info)['code'])
			{
				case NetStatusCode.NETCONNECTION_CONNECT_SUCCESS:
					setupStream();
					break;
				case NetStatusCode.NETGROUP_CONNECT_SUCCESS:
					peerID = nc.nearID;

					_ready = true;
					break;
				case NetStatusCode.NETGROUP_NEIGHBOUR_CONNECT:
					group.receiveMode = NetGroupReceiveMode.NEAREST;

					neighbour = nc.farID;
					groupAddress = group.convertPeerIDToGroupAddress(neighbour);	
					break;
				case NetStatusCode.NETGROUP_NEIGHBOUR_DISCONNECT:
					break;
				case NetStatusCode.NETGROUP_LOCAL_COVERAGE_NOTIFY:
//					trace('local coverage: '+group.localCoverageFrom+' to '+group.localCoverageTo+' estimated:'+group.estimatedMemberCount+' neighbours:'+group.neighborCount);
					break;
				case NetStatusCode.NETGROUP_SENDTO_NOTIFY:// e.info.message, e.info.from, e.info.fromLocal
					var msg:* = Object(e.info)['message'];
					if(msg is VOLogMessage)
					{
						if(peerID == VOLogMessage(msg).peer){
							//my own message, so ignore
						}else{
							//cannot send to another P2P thats in the same application with same id (!).
							group.sendToNeighbor(VOLogMessage(msg), NetGroupSendMode.NEXT_INCREASING);
						}
					}
					break;
			}
		}
		
		private function setupStream() : void 
		{
			var groupSpec:GroupSpecifier = new GroupSpecifier(groupID);			
            groupSpec.routingEnabled = true;
            groupSpec.ipMulticastMemberUpdatesEnabled = true;
            groupSpec.addIPMulticastAddress("225.225.0.1:30000");

            group = new NetGroup(nc, groupSpec.groupspecWithAuthorizations());
            group.addEventListener(NetStatusEvent.NET_STATUS, netStatus,false,9999);
		}
		
		public function dispose() : void
		{
			if(group)
			{
				group.removeEventListener(NetStatusEvent.NET_STATUS, netStatus);
				group.close();
			}
			group = null;
			
			if(nc)
			{
				nc.removeEventListener(NetStatusEvent.NET_STATUS, netStatus);
				nc.close();
			}
			nc = null;
		}

		public function send(input : String, level : int) : void
		{
			var vo:VOLogMessage = new VOLogMessage();
			vo.id = id++;
			vo.msg = input;
			vo.level = level;
			vo.peer = peerID;

			if(group.neighborCount == 0){
				connectionWarning('Log.x(): No neighbour found to connect with.');
			}else{
				var result:String = group.sendToNeighbor(vo,NetGroupSendMode.NEXT_INCREASING);
				if(result == NetGroupSendResult.ERROR)
				{
					connectionWarning('Log.x(): Remote error, could not make remote network.');
				}
			}
		}
		
		private function connectionWarning(input:String):void
		{
			if(!connectionWarningReported)
			{
				connectionWarningReported = true;
				trace(input);
			}
		}

		public function get ready() : Boolean
		{
			return _ready;
		}
	}
}