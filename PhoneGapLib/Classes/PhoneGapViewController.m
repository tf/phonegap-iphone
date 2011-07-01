/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2005-2010, Nitobi Software Inc.
 */


#import "PhoneGapViewController.h"
#import "PhoneGapDelegate.h" 

@implementation PhoneGapViewController

@synthesize supportedOrientations, webView;

- (id) init
{
    if (self = [super init]) {
		// do other init here
	}
	
	return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation 
{
	// First ask the webview via JS if it wants to support the new orientation -jm
	int i = 0;
	
	switch (interfaceOrientation){

		case UIInterfaceOrientationPortraitUpsideDown:
			i = 180;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			i = -90;
			break;
		case UIInterfaceOrientationLandscapeRight:
			i = 90;
			break;
		default:
		case UIInterfaceOrientationPortrait:
			// noop
			break;
	}
	
	NSString* jsCall = [ NSString stringWithFormat:@"shouldRotateToOrientation(%d);",i];
	NSString* res = [webView stringByEvaluatingJavaScriptFromString:jsCall];
	
	if([res length] > 0)
	{
		return [res boolValue];
	}
	
	// if js did not handle the new orientation ( no return value ) we will look it up in the plist -jm
	
	BOOL autoRotate = [self.supportedOrientations count] > 0; // autorotate if only more than 1 orientation supported
	if (autoRotate)
	{
		if ([self.supportedOrientations containsObject:
			 [NSNumber numberWithInt:interfaceOrientation]]) {
			return YES;
		}
    }
	
	// default return value is NO! -jm
	
	return NO;
}

/**
 Called by UIKit when the device starts to rotate to a new orientation.  This fires the \c setOrientation and the 
 \c triggerOrientationChanging method on the Orientation object in JavaScript.  Look at the JavaScript documentation 
 for more information.
 */
- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration: (NSTimeInterval)duration {
	int i = 0;
	
	switch (toInterfaceOrientation){
		case UIInterfaceOrientationPortrait:
			i = 0;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			i = 180;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			i = -90;
			break;
		case UIInterfaceOrientationLandscapeRight:
			i = 90;
			break;
	}
	
	NSString* jsCallback = [NSString stringWithFormat:@"window.__defineGetter__('orientation',function(){ return %d; }); PhoneGap.fireEvent('orientationchanging', window);",i];
	[webView stringByEvaluatingJavaScriptFromString:jsCallback];
}

/**
 Called by the UIKit whe the device has rotated to a new orientation. This fires the \c triggerOrientationChanged 
 method on the Orientation object in Javascript.
 */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	NSString* jsCallback = @"PhoneGap.fireEvent('orientationchange', window);";
	[webView stringByEvaluatingJavaScriptFromString:jsCallback];
}

- (void) setWebView:(UIWebView*) theWebView {
    webView = theWebView;
}

@end
