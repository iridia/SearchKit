//	SearchKit.j
//	Evadne Wu at Iridia, 2010
	
	
	
	

@implementation SearchKit : CPObject
	
+ (void) performLocalSearchWithTerm:(CPString)inTerm callback:(Function)inCallback {
	
	performWhenGoogleMapsScriptLoaded(/* (void) */ function  () {

		//	Do something, then send the results to the callback

	});
	
}
	
@end
	
	
	
	
	
//	Google API Loader.
//	Original code borrowed from 280north/MapKit.
	
	var GoogleSearchScriptQueue = [];
	
	var performWhenGoogleSearchScriptLoaded = function(/*Function*/ aFunction) {

		GoogleSearchScriptQueue.push(aFunction);

	//	Swizzle self out
		performWhenGoogleSearchScriptLoaded = function() { GoogleSearchScriptQueue.push(aFunction); }

	//	If Google Search is loaded, there is no need to load the script again
		if (window.google && google.search) return SearchKitSearchScriptLoaded();

	//	Otherwise, pull the script down from Google and wait
		var DOMScriptElement = document.createElement("script");
		DOMScriptElement.src = "http://www.google.com/jsapi?callback=_SearchKitGoogleAjaxLoaderLoaded";
		DOMScriptElement.type = "text/javascript";

		document.getElementsByTagName("head")[0].appendChild(DOMScriptElement);

	}
	
	
	
	
	
	function _SearchKitGoogleAjaxLoaderLoaded () {

		google.load("search", "1", {

			"callback": _SearchKitSearchScriptLoaded
			
		});

		[[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];

	}
	
	
	
	
	
	function _SearchKitSearchScriptLoaded() {

	//	Swizzle off delayed performing

		performWhenGoogleMapsScriptLoaded = function(aFunction) { aFunction(); }

		var index = 0, count = GoogleMapsScriptQueue.length;
		for (; index < count; ++index) GoogleMapsScriptQueue[index]();

		[[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];

	}
	
	
	
	
	