##Android/iOS App for e-fon portal access

This app enables streamlined e-fon portal from mobile devices. Currently  diversion, queues, SMS and Accounts are available.

The portal connection is currently achieved with HTTP encrypted TLS. The conventional HTML is loaded and parsed manually using regular expressions. Variables are POSTed using the AS3 "URLRequestMethod".

The build1.fla and build.as are the main Flash documents and program class. The build.apk is the final Android ready build. It can be download and manually installed on your Android device, as long as the "Installation of apps from unknown sources" is checked. This setting can usually be found in the settings > security > device administration. The build1.swf is used for desktop based testing. The build1-app.xml file is used from defining app permissions.

##How to install on android

1. Enable the setting "Installation of apps from unknown sources". Usually found in the settings > security > device administration

2. Download the build.apk file.

3. Choose the file from your download manager and follow the onscreen instructions.

##How to install on iOS

Will be updated once iOS nightly build is ready.

##Mavin.as (currently being implemented)
Currently all functions that contain server communications are being rewritten (Issue #7) into a separate class, Mavin.as. Calling the function will look like this ```load[page](method);```. The respective functions will return the desired server side variables.

###Authorization
```Actionscript
mavin.addEventListener(Event.AUTHORIZED, getAuthStatus)
var authorization:String = mavin.authorize(username, password);
```

Mavin will parse the return data from the initial authorization loader, detect available functionality, and loading respective modules. At any point load functions can be called, e.g ```ActionScript mavin.loadRedirection(method)```. For most modules the conventional POST or GET methods can be used, otherwise Mavin will inform you, for example ```ActionScript mavin.loadQueue("POST")``` must contain the AgentID within the function variable.

##Screen scaling
The .fla is designed for a 320x480, although not optimal the .as will attempt to scale all vectors appropriately. scaleX forcefully scales to the width and scaleY matches X:
```Actionscript
for each(var item in stageObjects)
{
	item.scaleX = stage.stageWidth / 320;
	item.scaleY = stage.stageWidth / 320;
}
```
