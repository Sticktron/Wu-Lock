//
//  Wu-Lock
//  Custom lock glyphs for the children.
//
//  Created by Sticktron.
//  Copyright (c) 2015. All rights reserved.
//
//

#define DEBUG_PREFIX @"🍓  [Wu-Lock]"
#import "DebugLog.h"

#import <UIKit/UIKit.h>


// Constants.

static const float kMarginBottom = 110.0f;
static NSString * const kDefaultGlyph = @"/Library/Application Support/Wu-Lock/Default/wutang.png";

static CFStringRef const kPrefsAppID = CFSTR("com.sticktron.wu-lock");



// Globals.

static BOOL enabled;
static NSString *selectedGlyph;
static NSString *style;
static float yOffset;
static BOOL noDelay;
static BOOL hideChevron;
static BOOL useCustomText;
static NSString *customText;
static BOOL useCustomBioText;
static NSString *customBioText;
static int dimTimeout;



// Helpers.

static inline void loadSettings() {
	DebugLogC(@"loadSettings() called.");
	
	NSDictionary *settings = nil;
	
	CFPreferencesAppSynchronize(kPrefsAppID);
	CFArrayRef keyList = CFPreferencesCopyKeyList(kPrefsAppID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList) {
		settings = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, kPrefsAppID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		DebugLogC(@"Got user settings from Prefs: %@", settings);
		CFRelease(keyList);
	} else {
		DebugLogC(@"Error getting key list from Prefs!");
	}
	
	enabled = settings[@"Enabled"] ? [settings[@"Enabled"] boolValue] : YES;
	DebugLogC(@"enabled=%d", enabled);
	
	selectedGlyph = settings[@"SelectedGlyph"] ? settings[@"SelectedGlyph"] : kDefaultGlyph;
	DebugLogC(@"selectedGlyph=%@", selectedGlyph);
	
	style = settings[@"Style"] ? settings[@"Style"] : @"vibrantBlur";
	DebugLogC(@"style=%@", style);
	
	yOffset = settings[@"YOffset"] ? [settings[@"YOffset"] floatValue] : 0;
	DebugLogC(@"yOffset=%f", yOffset);
	
	noDelay = settings[@"NoDelay"] ? [settings[@"NoDelay"] boolValue] : YES;
	DebugLogC(@"noDelay=%d", noDelay);
	
	hideChevron = settings[@"HideChevron"] ? [settings[@"HideChevron"] boolValue] : YES;
	DebugLogC(@"hideChevron=%d", hideChevron);
	
	useCustomText = settings[@"UseCustomText"] ? [settings[@"UseCustomText"] boolValue] : YES;
	DebugLogC(@"useCustomText=%d", useCustomText);
	
	customText = settings[@"CustomText"] ? settings[@"CustomText"] : @"Protect ya neck";
	DebugLogC(@"customText=%@", customText);
	
	useCustomBioText = settings[@"UseCustomBioText"] ? [settings[@"UseCustomBioText"] boolValue] : YES;
	DebugLogC(@"useCustomBioText=%d", useCustomBioText);
	
	customBioText = settings[@"CustomBioText"] ? settings[@"CustomBioText"] : @"Shame on a finga";
	DebugLogC(@"customBioText=%@", customBioText);
	
	dimTimeout = settings[@"DimTimeout"] ? [settings[@"DimTimeout"] intValue] : 8;
	DebugLogC(@"dimTimeout=%d", dimTimeout);
}

static inline void reloadSettings(CFNotificationCenterRef center, void *observer, CFStringRef name,
								  const void *object, CFDictionaryRef userInfo) {
	DebugLogC(@"***** Got a Settings Changed notification *****");
	loadSettings();
}

@implementation UIImage (Private)
+ (UIImage *)imageWithCorrectedScale:(UIImage *)image {
	BOOL opaque = NO;
	CGSize size = image.size;
	
	UIGraphicsBeginImageContextWithOptions(size, opaque, 0);
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}
@end



// Private interfaces.

@interface SBBacklightController : NSObject
- (double)defaultLockScreenDimInterval;
@end

@interface SBLockScreenScrollView : UIScrollView
@end

@interface SBLockScreenView : UIView
- (id)_defaultSlideToUnlockText;
- (void)setCustomSlideToUnlockText:(id)arg1 animated:(_Bool)arg2;
- (void)shakeSlideToUnlockTextWithCustomText:(id)arg1;
@end

@interface SBLockScreenViewController : UIViewController
- (BOOL)shouldShowSlideToUnlockTextImmediately;
- (void)shakeSlideToUnlockTextWithCustomText:(id)arg1;
- (id)effectiveCustomSlideToUnlockText;
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

@interface UIColor (Private)
+ (id)_vibrantDarkFillDodgeColor;
+ (id)_vibrantLightFillDarkeningColor;
+ (id)_vibrantLightFillBurnColor;
+ (id)_vibrantLightDividerDarkeningColor;
+ (id)_vibrantLightDividerBurnColor;
@end



// Hooks.

%hook SBBacklightController
- (double)defaultLockScreenDimInterval {
	if (enabled) {
		return dimTimeout;
	} else {
		return %orig; // 8 seconds
	}
}
%end


%hook SBLockScreenView
- (id)_defaultSlideToUnlockText {
	id result = %orig;
	DebugLog(@"result=%@", result);
	return result;
}
- (void)setCustomSlideToUnlockText:(id)arg1 animated:(_Bool)arg2 {
	DebugLog(@"arg1=%@", arg1);
	%orig;
}
- (void)shakeSlideToUnlockTextWithCustomText:(id)arg1 {
	DebugLog(@"arg1=%@", arg1);
	
	if (enabled && useCustomBioText) {
		%orig(customBioText);
	} else {
		%orig;
	}
}
%end


%hook SBLockScreenViewController
- (id)effectiveCustomSlideToUnlockText {
	id result = %orig;
	DebugLog(@"result=%@", result);
	return result;
}
- (void)shakeSlideToUnlockTextWithCustomText:(id)arg1 {
	DebugLog(@"arg1=%@", arg1);
	
	if (enabled && useCustomBioText) {
		%orig(customBioText);
	} else {
		%orig;
	}
}
- (BOOL)shouldShowSlideToUnlockTextImmediately {
	if (enabled && noDelay) {
		return YES;
	} else {
		return NO;
	}
}
%end


%hook SBLockScreenScrollView
- (id)initWithFrame:(CGRect)frame {
	DebugLog0;
	
	if (!enabled) return %orig;
	
	if ((self = %orig)) {
		DebugLog(@"Creating glyph for: selectedGlyph=%@", selectedGlyph);
		
		// load image
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:selectedGlyph];
		if (image) {
			DebugLog(@"loaded image with size=%@ and scale=%f", NSStringFromCGSize(image.size), image.scale);
			
			// custom images may not have @2x/@3x suffixes,
			// so let's manually match them to screen scale
			if (image.scale != [UIScreen mainScreen].scale) {
				DebugLog(@"image needs scale adjusted!");
				//image = [UIImage imageWithCorrectedScale:image];
				
				image = [[UIImage alloc] initWithCGImage:image.CGImage
												   scale:[UIScreen mainScreen].scale
											 orientation:UIImageOrientationUp];
				
				DebugLog(@"image now has size: %@ and scale: %f", NSStringFromCGSize(image.size), image.scale);
			}
		} else {
			DebugLog(@"image not found :(");
			// TODO: do something?
		}
		
		
		// Style Selecta ...
/*

 //@"white";
 //@"black";
 //@"yellow";
 //@"vibrantBlur";
 //@"burntBlur";
 //@"original";

 
_UIBackdropViewSettingsAdaptiveLight
_UIBackdropViewSettingsBlur
_UIBackdropViewSettingsColorSample
_UIBackdropViewSettingsColored
_UIBackdropViewSettingsCombiner
_UIBackdropViewSettingsDark
_UIBackdropViewSettingsDarkLow
_UIBackdropViewSettingsDarkWithZoom
_UIBackdropViewSettingsFlatSemiLight
_UIBackdropViewSettingsLight
 _UIBackdropViewSettingsLightKeyboard
 _UIBackdropViewSettingsLightLow
 _UIBackdropViewSettingsNonAdaptive
 _UIBackdropViewSettingsNone
 _UIBackdropViewSettingsPasscodePaddle
 _UIBackdropViewSettingsSemiLight
 _UIBackdropViewSettingsUltraColored
 _UIBackdropViewSettingsUltraDark
 _UIBackdropViewSettingsUltraLight
 _UIBackgroundHitTestWindow
 		if ([style isEqualTo:kWUStyleWhite] || [style isEqualTo:kWUStyleBlack] || [style isEqualTo:kWUStyleYellow]) {
			// flat color styles
		}
*/
		
		// create blur view
		CGRect frame = (CGRect){{0, 0}, image.size};
		_UIBackdropView *glyphBlurView = [[_UIBackdropView alloc] initWithFrame:frame style:3900];
		//_UIBackdropView *glyphBlurView = [[_UIBackdropView alloc] initWithFrame:frame style:2060];
		
		// create mask
		CALayer *maskLayer = [CALayer layer];
		maskLayer.frame = glyphBlurView.bounds;
		maskLayer.contents = (id)image.CGImage;
		glyphBlurView.layer.mask = maskLayer;
		
		// set position
		CGRect screenRect = [UIScreen mainScreen].bounds;
		float x = screenRect.size.width + CGRectGetMidX(screenRect);
		float y = screenRect.size.height - kMarginBottom - (image.size.height/2.0) - yOffset;
		glyphBlurView.center = (CGPoint){x, y};
		
		// some styles require a second layer of glyph...
		
//		//UIImageView *glyphImageView = [[UIImageView alloc] initWithImage:image];
//		UIImageView *glyphImageView = [[UIImageView alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
//		glyphImageView.tintColor = [UIColor colorWithWhite:1 alpha:0.2];
//		[glyphImageView _setDrawsAsBackdropOverlayWithBlendMode:kCGBlendModeColorDodge];
//		
//		//		glyphImageView.tintColor = [UIColor _vibrantDarkFillDodgeColor];
//		//		[glyphImageView _setDrawsAsBackdropOverlayWithBlendMode:kCGBlendModeColorDodge];
		
//		[glyphBlurView.contentView addSubview:glyphImageView];
//		[glyphImageView release];
		
		[self addSubview:glyphBlurView];
		
		
		
	//		// test stuff ////////
	//
	//		_UIGlintyStringView *glintyView = MSHookIvar<id>(self, "_slideToUnlockView");
	//
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
	
	}
	return self;
}

/*
- (void)willMoveToWindow:(id)arg1 {
	DebugLog(@"arg1=%@", arg1);
	%orig;
}

- (void)didMoveToWindow {
	DebugLog0;
	%orig;
}
*/

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



// Constructor.

%ctor {
    @autoreleasepool {
		NSLog(@"Wu-Lock Yo!");
		%init;
		loadSettings();
		
		// listen for notifications from Settings
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)reloadSettings,
										CFSTR("com.sticktron.wu-lock.settingschanged"),
										NULL,
										CFNotificationSuspensionBehaviorDeliverImmediately);
		
	}
}

