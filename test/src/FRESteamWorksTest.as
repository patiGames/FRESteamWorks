/*
 *  FRESteamWorks.h
 *  This file is part of FRESteamWorks.
 *
 *  Created by David ´Oldes´ Oliva on 3/29/12.
 *  Contributors: Ventero <http://github.com/Ventero>
 *  Copyright (c) 2012 Amanita Design. All rights reserved.
 *  Copyright (c) 2012-2013 Level Up Labs, LLC. All rights reserved.
 */

package
{
	import com.amanitadesign.steam.FRESteamWorks;
	import com.amanitadesign.steam.SteamConstants;
	import com.amanitadesign.steam.SteamEvent;

	import flash.desktop.NativeApplication;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.ByteArray;

	public class FRESteamWorksTest extends Sprite
	{
		public var Steamworks:FRESteamWorks = new FRESteamWorks();
		public var tf:TextField;
		public function FRESteamWorksTest()
		{
			tf = new TextField();
			tf.width = stage.stageWidth;
			tf.height = stage.stageHeight;
			addChild(tf);

			tf.addEventListener(MouseEvent.MOUSE_DOWN, onClick);

			Steamworks.addEventListener(SteamEvent.STEAM_RESPONSE, onSteamResponse);
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExit);
			try {
				Steamworks.useCrashHandler(480, "1.0", "Feb 20 2013", "21:42:20");
				if(!Steamworks.init()){
					tf.appendText("STEAMWORKS API is NOT available\n");
					return;
				}

				log("STEAMWORKS API is available\n");
				log("User ID: " + Steamworks.getUserID());
				log("Persona name: " + Steamworks.getPersonaName());

				//comment.. current stats and achievement ids are from steam example app which is provided with their SDK
				log("isAchievement('ACH_WIN_ONE_GAME') == "+Steamworks.isAchievement("ACH_WIN_ONE_GAME"));
				log("isAchievement('ACH_TRAVEL_FAR_SINGLE') == "+Steamworks.isAchievement("ACH_TRAVEL_FAR_SINGLE"));
				log("setStatFloat('FeetTraveled') == "+Steamworks.setStatFloat('FeetTraveled', 21.3));
				log("setStatInt('NumGames', 2) == "+Steamworks.setStatInt('NumGames', 2));
				Steamworks.storeStats();
				log("getStatInt('NumGames') == "+Steamworks.getStatInt('NumGames'));
				log("getStatFloat('FeetTraveled') == "+Steamworks.getStatFloat('FeetTraveled'));

				log("setCloudEnabledForApp(false) == "+Steamworks.setCloudEnabledForApp(false) );
				log("setCloudEnabledForApp(true) == "+Steamworks.setCloudEnabledForApp(true) );
				log("isCloudEnabledForApp() == "+Steamworks.isCloudEnabledForApp() );
				log("getFileCount() == "+Steamworks.getFileCount() );
				log("fileExists('test.txt') == "+Steamworks.fileExists('test.txt') );

				//comment.. writing to app with id 480 is somehow not working, but works with our real appId
				log("writeFileToCloud('test.txt','hello steam') == "+writeFileToCloud('test.txt','hello steam'));
				log("readFileFromCloud('test.txt') == "+readFileFromCloud('test.txt') );
				//-----------

				//Steamworks.requestStats();
				Steamworks.resetAllStats(true);
			} catch(e:Error) {
				tf.appendText("*** ERROR ***");
				tf.appendText(e.message + "\n");
				tf.appendText(e.getStackTrace() + "\n");
			}

		}
		private function log(value:String):void{
			tf.appendText(value+"\n");
			tf.scrollV = tf.maxScrollV;
		}
		public function writeFileToCloud(fileName:String, data:String):Boolean {
			var dataOut:ByteArray = new ByteArray();
			dataOut.writeUTFBytes(data);
			return Steamworks.fileWrite(fileName, dataOut);
		}

		public function readFileFromCloud(fileName:String):String {
			var dataIn:ByteArray = new ByteArray();
			var result:String;
			dataIn.position = 0;
			dataIn.length = Steamworks.getFileSize(fileName);

			if(dataIn.length>0 && Steamworks.fileRead(fileName,dataIn)){
				result = dataIn.readUTFBytes(dataIn.length);
			}
			return result;
		}

		public function onClick(e:MouseEvent):void{
			log("--click--");
			if(!Steamworks.isReady){
				log("not able to set achievement\n");
				return;
			}

			if(!Steamworks.isAchievement("ACH_WIN_ONE_GAME")) {
				log("setAchievement('ACH_WIN_ONE_GAME') == "+Steamworks.setAchievement("ACH_WIN_ONE_GAME"));
			} else {
				log("clearAchievement('ACH_WIN_ONE_GAME') == "+Steamworks.clearAchievement("ACH_WIN_ONE_GAME"));
			}
			if(Steamworks.fileExists('test.txt')){
				log("readFileFromCloud('test.txt') == "+readFileFromCloud('test.txt') );
				log("Steamworks.fileDelete('test.txt') == "+Steamworks.fileDelete('test.txt'));
			} else {
				log("writeFileToCloud('test.txt','click') == "+writeFileToCloud('test.txt','click'));
			}
			//Steamworks.storeStats();
		}

		public function onSteamResponse(e:SteamEvent):void{
			switch(e.req_type){
				case SteamConstants.RESPONSE_OnUserStatsStored:
					log("RESPONSE_OnUserStatsStored: "+e.response);
					break;
				case SteamConstants.RESPONSE_OnUserStatsReceived:
					log("RESPONSE_OnUserStatsReceived: "+e.response);
					break;
				case SteamConstants.RESPONSE_OnAchievementStored:
					log("RESPONSE_OnAchievementStored: "+e.response);
					break;
				default:
					log("STEAMresponse type:"+e.req_type+" response:"+e.response);
			}
		}

		public function onExit(e:Event):void{
			log("Exiting application, cleaning up");
			Steamworks.dispose();
		}
	}
}
