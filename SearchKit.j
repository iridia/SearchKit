//	SearchKit.j
//	Evadne Wu at Iridia, 2010
	
	
	
	

@import <AppKit/AppKit.j>
@class IRProtocol;





var _SKFoundation_sharedFoundation = nil;










@implementation SKFoundation : CPObject {
	
	DOMElement _DOMContainerElement;
	
}





+ (SKFoundation) sharedFoundation {

	if (_SKFoundation_sharedFoundation != nil) return _SKFoundation_sharedFoundation;
	_SKFoundation_sharedFoundation = [[[self class] alloc] init];
	return _SKFoundation_sharedFoundation;
	
}





- (SKFoundation) init {
	
	self = [super init]; if (self == nil) return nil;
	
	[self createDOMWrapper];
	
	return self;
	
}





- (void) createDOMWrapper {
	
	_DOMContainerElement = document.createElement("div");
	_DOMContainerElement.id = CPStringFromClass([self class]) + [self UID];

	var style = _DOMContainerElement.style;

	style.overflow = "hidden";
	style.position = "absolute";
	style.visibility = "visible";
	style.zIndex = 0;
	style.left = "-128px";
	style.top = "-128px";
	style.width = "128px";
	style.height = "128px";
	
	document.body.appendChild(_DOMContainerElement);
	
}




@end










@implementation SKSearchControl : CPObject {
	
	BOOL isSearching;
	CPArray searchers;
	CPArray searchResults;
	
	id _delegate @accessors;
	
}





+ (IRProtocol) irDelegateProtocol {

	return [IRProtocol protocolWithSelectorsAndOptionalFlags:

		@selector(searchControl:didReturnResults:), false

	];

}





+ (SKSearchControl) controlWithSearchers:(CPArray)searchers {
	
	var theSearchControl = [[[self class] alloc] init];
	if (theSearchControl == nil) return nil;

	var enumerator = [searchers objectEnumerator]; var searcher; while (searcher = [enumerator nextObject]) {
		
		[searcher irSetDelegate:self];
		[searchers addObject:searcher];
	
	}
	
	return theSearchControl;
	
}





- (SKSearchControl) init {
	
	self = [super init]; if (self == nil) return nil;
	
	searchers = [CPMutableArray array];
	
	return self;
	
}





- (CPString) description {
	
	return [super description] + @" — With Searchers: " + [searchers description];
	
}





- (void) startQuery {
	
	if ([self delegate] == nil)
	return CPLog(@"Warning — Search Control does not have a delegate, its response will not be heard by anybody");
	
	var enumerator = [[self searchers] objectEnumerator], searcher; while (searcher = [enumerator nextObject])
	[searcher startQuery];
	
}





- (void) searcher:(SKSearcher)searcher didReturnResults:(CPArray)results {
	
	CPLog(@"A search %@ has returned results!", searcher);
	
	//	Everybody done?
			
}
	
	
	
	
	
@end










@implementation SKSearcher : CPObject {
	
	Object searcher @accessors;
	CPString queryExpression @accessors;
	
	id delegate;
	
}

+ (IRProtocol) irDelegateProtocol {
	
	return [IRProtocol protocolWithSelectorsAndOptionalFlags:
	
		@selector(searcher:didReturnResults:), false
	
	];
	
}

- (void) execute {
	
	//	This method is to be overriden, and [super execute] called at the end of the overriding method.
	//	in execute, the method makes sure all dependencies are sound and strong, then attempt to load the results.
	//	As the results came in, the searcher calls its delegate which aggregates and makes more callbacks.

	if ([self delegate] == nil)
	CPLog(@"Warning: SKSearcher %@ does not have a delegate, so its results will leak away.", self);

//	searcher.execute(queryExpression);
	
}

@end










@implementation SKLocalSearcher : SKSearcher {
	
	CLLocationCoordinate2D centerCoordinate @accessors;
	
}




	
+ (SKLocalSearcher) searcherWithExpression:(CPString)queryExpression centerCoordinate:(CLLocationCoordinate2D)centerCoordinateOrNil {
	
	var searcher = [[self alloc] init];
		
	// if (centerCoordinateOrNil != nil)
	// [searcher setCenterCoordinate:centerCoordinateOrNil];
	// 
	// [searcher setQueryExpression:queryExpression];
	
	return searcher;
	
}





- (void) execute {
	
	[self setSearcher:(new google.search.LocalSearch())];
	
	if (centerCoordinate != nil)
	searcher.setCenterPoint(LatLngFromCLLocationCoordinate2D(centerCoordinate));
	
	[super execute];
	
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
	
	
	
	
	
	var searchKit_GoogleMapsScriptQueue = [];

	var searchKit_performWhenGoogleMapsScriptLoaded = function(/*Function*/ aFunction) {

		searchKit_GoogleMapsScriptQueue.push(aFunction);

	//	Swizzle self out
		searchKit_performWhenGoogleMapsScriptLoaded = function() { GoogleMapsScriptQueue.push(aFunction); }

	//	If Google Maps is loaded, there is no need to load the script again
		if (window.google && google.maps) return _searchKit_MKMapViewMapsLoaded();

	//	Otherwise, pull the script down from Google and wait
		var DOMScriptElement = document.createElement("script");
		DOMScriptElement.src = "http://www.google.com/jsapi?callback=_MKMapViewGoogleAjaxLoaderLoaded";
		DOMScriptElement.type = "text/javascript";

		document.getElementsByTagName("head")[0].appendChild(DOMScriptElement);

	}

	function _searchKit_MKMapViewGoogleAjaxLoaderLoaded () {
	
		google.load("maps", "3.2", {
	
			"callback": _searchKit_MKMapViewMapsLoaded,
			"other_params": "sensor=false"
		
		});

		[[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];

	}
	
	function _searchKit_MKMapViewMapsLoaded () {

	//	Swizzle off delayed performing
	
		performWhenGoogleMapsScriptLoaded = function(aFunction) { aFunction(); }
		
		var index = 0, count = searchKit_GoogleMapsScriptQueue.length;
		for (; index < count; ++index) searchKit_GoogleMapsScriptQueue[index]();

		[[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
	
	}
	
	
	
	
	
	
	
	
	
	