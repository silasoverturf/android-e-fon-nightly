package
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;

	public class Mavin extends MovieClip
	{
		//local
		public var userID_local:String;
		public var password_local:String;

		public var realm:String = "web.e-fon.ch";
		public var context:String = "/portal"

		public var debugLevel:Number = 1;

		//
		public var invalidPW:Boolean;
		public var isAdmin:Boolean;

		public var mavinState:String;
		
		//check what web
		public var checkSend:URLRequest = new URLRequest("https://" + realm);
		public var checkLoader:URLLoader = new URLLoader;
		public var checkRex:RegExp = /;.>([^<]{0,})/;

		//session
		public var jSend:URLRequest = new URLRequest("https://" + realm + context +"/j_acegi_security_check");
		public var jLoader:URLLoader;
		public var jSession:URLVariables;
		public var jData:String;

		public function Mavin()
		{
			checkLoader.load(checkSend);
			checkLoader.addEventListener(Event.COMPLETE, parse);

			var result:Array;

			function parse(event:Event):void
			{
				result = checkRex.exec(checkLoader.data)
				trace(result[1]  + ", Mavin is ready");
			}
		}

		public function authorize(user:String, password:String):void
		{
			trace("Mavin is authorizing");

			userID_local = user;
			password_local = password;

			jSession = new URLVariables();
			jLoader = new URLLoader();

			jSession.j_username = userID_local;
			jSession.j_password = password_local;

			jSend.method = URLRequestMethod.POST;
			jSend.data = jSession

			jLoader.load(jSend)

			jLoader.addEventListener(Event.COMPLETE, parse);

			function parse(event:Event):void
			{
				invalidPW = false;
				isAdmin = false;

				jData = jLoader.data;

				if(jData.search("password") > -1){invalidPW = true;if(debugLevel == 1){trace("Password is invalid")}}

				if(jData.search("memberOverview") > -1){isAdmin = true;if(debugLevel == 1){trace("User is admin")}}

				if(invalidPW == false && isAdmin == false)
				{
				}
				dispatchEvent(new Event("authComplete"));
			}
		}
		
		//just for testing;
		public function doMath(value1:Number, value2:Number)
		{
			var dump:Number = value1 + value2;

			trace(dump)
			return dump;
		}
	}
}