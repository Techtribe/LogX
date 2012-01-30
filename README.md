LogX
====
A lightweight logging setup that helps you with local and remote debugging in Actionscript 3.
It is made for logging your traces in a more configurable way and has the following features:

* Log String messages like **<code>trace();</code>** but with log levels and restrict/skip level functionality.
* Log all or specific **properties** of a (Display)Object.
* Log all Stage **children** or below a specific Point(x,y).
* Log with additional information like **memory usage** and/or **timestamp**.
* Use it with your Actionscript (**AIR**/**FP**) project and listen to remote logging sessions (**WiFi** or **wired**) on Mac OSX or Windows.

Install
-------
Before using LogX check for what purpose you will need it:

* Download **<code>logx.swc</code>** to use inside your project as a library swc or download the <code>nl.techtribe.logx</code> classes.
* For remote logging (outside your computer) download the **AIR application** to log through RTMFP.
* To utilize your **flashlog.txt** you can markup your console in Eclipse with
  * [Grep Console](http://eclipse.musgit.com "Grep Console") : to color your flashlog-console inside Eclipse and check [this](http://marian.musgit.com/grepconsole/index.html "Userguide") to discover how to customize the colors.

Usage
-----

### Local/Remote
The most important functionality is the switch between local (on your computer) and remote (through RTMFP) logging. Local logging is default, but you can switch anytime with:  
<code>
	Log.remoteID = 'nl.techtribe.test'; 
	Log.remote = true; //RTMFP will be activated
</code>  
Where  
<code>
	Log.remoteID = 'nl.techtribe.test';
</code>  
will be used as an unique identifier used to identify the session in your listen-AIR-application. It is **IMPORTANT** to always set this property before starting the remote (RTMFP) session with:  
<code>
	Log.remote = true;
</code>  

### Trace Functionality
A few options are available to you, when tracing your message:

* simple : 
  * <code>Log.x('info');</code>
  * <code>Log.x('anyotherstring or with some space!');</code>
* with levels :
  * <code>Log.x('An info message  ',Log.INFO);</code> //default log level
  * <code>Log.x('A warning message',Log.WARNING);</code>
  * <code>Log.x('A debug message  ',Log.DEBUG);</code>
  * <code>Log.x('An error message ',Log.ERROR);</code>
* with properties :
  * <code>Log.x(new Shape,Log.INFO,Vector.<String>(['x','y','scaleX','scaleY']));</code>
* with objects :
  * <code>Log.x(new MovieClip);</code>
  * <code>Log.x(new Shape);</code>
  * <code>var s:Object;Log.x(s);</code>
  * <code>Log.x(new Sprite,Log.DEBUG,Vector.<String>(['scaleX','x']));</code>
* with null-objects without runtime errors : 
  * <code>Log.x(null);</code>
  * <code>Log.x(undefined);</code>
* restrict which levels are accepted :
  * <code>Log.restrict([Log.DEBUG]);</code>
  * <code>Log.restrict(Vector.<int>([Log.DEBUG,LOG.WARNING]));</code>
* skip certain levels :
  * <code>Log.skip([Log.DEBUG]);</code>
  * <code>Log.skip(Vector.<int>([Log.DEBUG,LOG.WARNING]));</code>

### Stage children
You can also detect which children are available on the Stage. It is **IMPORTANT** to execute first  
<code>
	Log.stage = this.stage;
</code>  
to ensure LogX can access the Stage. *Note that you will need to have access before setting this stage-property!*  
Now you can discover the children by:  
<code>
	Log.children();
</code>  
or  
<code>
	Log.children(new Point(50,50));  
	Log.children(new Point(mouseX,mouseY));
</code>

Fork for whatever function you like to add or contact us at [Techtribe](mailto:opensource@techtribe.nl?subject=LogX "Techtribe").