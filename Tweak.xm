//
//  Wu-Lock
//  Custom lock glyphs for the children.
//
//  Created by Sticktron.
//  Copyright (c) 2014. All rights reserved.
//
//

#define DEBUG_PREFIX @"Wu-Lock"
#import "DebugLog.h"

#import <UIKit/UIKit.h>


@interface SBBacklightController : NSObject
- (void)_lockScreenDimTimerFired;
- (double)defaultLockScreenDimInterval;
@end

@interface SBLockScreenScrollView : UIScrollView
@end

@interface SBLockScreenView : UIView
- (void)_startAnimatingSlideToUnlockWithDelay:(double)arg1;
- (id)_defaultSlideToUnlockText;
- (void)_addViews;
- (void)setCustomSlideToUnlockText:(id)arg1 animated:(_Bool)arg2;
- (void)shakeSlideToUnlockTextWithCustomText:(id)arg1;
- (void)stopAnimating;
- (void)startAnimating;
- (void)setUsesCustomSlideToUnlockDisplayForWhiteBackground:(_Bool)arg1 forRequester:(id)arg2;
- (void)setSlideToUnlockBlurHidden:(_Bool)arg1 forRequester:(id)arg2;
- (void)setSlideToUnlockHidden:(_Bool)arg1 forRequester:(id)arg2;
- (void)willMoveToWindow:(id)arg1;
@end

@interface _UIGlintyStringView : UIView
@property(retain, nonatomic) UIView *backgroundView;
@end

@interface UIView (Private)
- (void)_setDrawsAsBackdropOverlayWithBlendMode:(long long)arg1;
@end

@interface _UIBackdropView : UIView
@property(nonatomic) BOOL blursBackground;
@property(retain, nonatomic) UIView *contentView;
@property(retain, nonatomic) UIImage *filterMaskImage;
- (id)initWithFrame:(CGRect)arg1 style:(int)arg2;
- (void)setMaskImage:(id)arg1 onLayer:(id)arg2;
- (id)backdropViewLayer;
@end





#define MARGIN_BOTTOM		100.0f
#define PATH_TO_GLYPHS		@"/Library/Application Support/WuLock"
#define DEFAULT_GLYPH		@"wutang.png"

static BOOL enabled;
static BOOL showSlideTextImmediately;



%hook SBBacklightController
- (double)defaultLockScreenDimInterval {
	// default is 8 seconds
	return 120;
}
%end


%hook SBLockScreenView
- (void)_startAnimatingSlideToUnlockWithDelay:(double)delay {
	if (showSlideTextImmediately) {
		%orig(0);
	} else {
		%orig;
	}
}
%end


%hook SBLockScreenScrollView

- (id)initWithFrame:(CGRect)frame {
	DebugLog0;
	
	if ((self = %orig)) {
		
		// load image
		NSString *path = [PATH_TO_GLYPHS stringByAppendingPathComponent:DEFAULT_GLYPH];
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
		DebugLog(@"loaded image (%@); size=%@", path, NSStringFromCGSize(image.size));
		
		
//		// test one ////////
//		
//		UIImageView *glyphView1 = [[UIImageView alloc]
//								   initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
//		
//		CGRect screenRect = [UIScreen mainScreen].bounds;
//		float x = screenRect.size.width + CGRectGetMidX(screenRect);
//		float y = screenRect.size.height - kMarginBottom - CGRectGetMidY(glyphView1.frame);
//		glyphView1.center = (CGPoint){x, y};
//		
//		glyphView1.tintColor = [UIColor colorWithWhite:0.65 alpha:1];
//		[glyphView1 _setDrawsAsBackdropOverlayWithBlendMode:kCGBlendModeOverlay];
//		//[glyphView1 _setDrawsAsBackdropOverlayWithBlendMode:kCGBlendModeColorDodge];
//		
//		
//		[self addSubview:glyphView1];
//		[glyphView1 release];
		
		
		
		
		// test two ////////
		CGRect frame = (CGRect){{0, 0}, image.size};
		_UIBackdropView *glyphView2 = [[_UIBackdropView alloc] initWithFrame:frame style:3900];
		//_UIBackdropView *glyphView2 = [[_UIBackdropView alloc] initWithFrame:frame style:2060];
		
//		glyphView2.layer.borderColor = UIColor.whiteColor.CGColor;
//		glyphView2.layer.borderWidth = 1.0f;
		
		
		// set up mask
		CALayer *maskLayer = [CALayer layer];
		maskLayer.frame = glyphView2.bounds;
		maskLayer.contents = (id)image.CGImage;
		glyphView2.layer.mask = maskLayer;
		
		
		// position
		CGRect screenRect = [UIScreen mainScreen].bounds;
		float x = screenRect.size.width + CGRectGetMidX(screenRect);
		float y = screenRect.size.height - MARGIN_BOTTOM - (image.size.height/2);
		glyphView2.center = (CGPoint){x, y};
		
		// add the image on top of the backdrop
		//UIImageView *glyphView1 = [[UIImageView alloc] initWithImage:image];
		UIImageView *glyphView1 = [[UIImageView alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
		glyphView1.tintColor = [UIColor colorWithWhite:0.1 alpha:1];
		[glyphView1 _setDrawsAsBackdropOverlayWithBlendMode:kCGBlendModeOverlay];
		
		[glyphView2.contentView addSubview:glyphView1];
		[glyphView1 release];
		
		[self addSubview:glyphView2];
		[glyphView2 release];
		
		
//		_UIGlintyStringView *glintyView = MSHookIvar<id>(self, "_slideToUnlockView");

		[image release];
	}
	return self;
}

- (void)willMoveToWindow:(id)arg1 {
	DebugLog(@"arg1=%@", arg1);
	%orig;
}

- (void)didMoveToWindow {
	DebugLog0;
	%orig;
}


/*
- (void)layoutSubviews {
	DebugLog0;
	%orig;
}

- (void)_layoutSlideToUnlockView {
	DebugLog0;
	%orig;
	
//	_UIGlintyStringView *glintyView = MSHookIvar<id>(self, "_slideToUnlockView");
//	DebugLog(@"glintyView=%@", glintyView);
	
//	DebugLog(@"glyphView=%@", glyphView);
//	glyphView.center = glintyView.center;
//	glyphView.backgroundColor = UIColor.greenColor;
	
//	[glintyView addSubview:glyphView];
//	glintyView.backgroundView = glyphView;
//	glintyView.backgroundColor = UIColor.blackColor;
	
}
*/

%end




//	if (!wuView) {
//		wuView = YES;
//		DebugLog(@"creating Wu View");
//
//		UIView *slideView = MSHookIvar<id>(self, "_slideToUnlockView");
//		DebugLog(@"slidToUnlockView = %@", slideView);
//
//		CGRect frame = slideView.frame;
//		frame.origin.x = 100.0;
//		frame.origin.y -= 60.0;
//		frame.size.width = 60.0;
//		frame.size.height = 60.0;
//		
//		_UIGlintyGradientView *gv = [[%c(_UIGlintyGradientView) alloc] initWithFrame:frame];
//		gv.backgroundColor = UIColor.greenColor;
//		DebugLog(@"gv = %@", gv);
//		
//		NSString *path = @"/Library/PreferenceBundles/Boxy.bundle/Boxy.png";
//		UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
//		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];		
//		[gv addSubview:imageView];
//		
//		//id scrollView = MSHookIvar<id>(self, "_foregroundScrollView;");
//		// DebugLog(@"lockscreen ScrollView = %@", scrollView);
//		//
//		//[scrollView addSubview:gv];
//		[self addSubview:gv];
//		
//	}



%ctor {
    @autoreleasepool {
		NSLog(@"Wu-Tang Lock yo");
		
		// TODO: register for notifications
		// TODO: load prefs
		
		enabled = YES;
		showSlideTextImmediately = YES;
	}
}
