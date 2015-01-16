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



// Private interfaces.

@interface SBBacklightController : NSObject
- (double)defaultLockScreenDimInterval;
@end

@interface SBLockScreenView : UIView
- (id)_defaultSlideToUnlockText;
- (void)shakeSlideToUnlockTextWithCustomText:(id)arg1;
- (void)_startAnimatingSlideToUnlockWithDelay:(double)arg1;
- (void)_layoutSlideToUnlockView;
@end

@interface SBLockScreenScrollView : UIScrollView
@property(nonatomic) SBLockScreenView *lockScreenView;
- (id)glyphViewForStyle:(NSString *)style image:(UIImage *)image;
@end

@interface SBLockScreenViewController : UIViewController
- (BOOL)shouldShowSlideToUnlockTextImmediately;
@end

@interface UIView (Private)
- (void)_setDrawsAsBackdropOverlayWithBlendMode:(long long)arg1;
@end

@interface _UIBackdropView : UIView
@property(nonatomic) int style;
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

@interface _UIGlintyStringView : UIView
- (id)_chevronImageForStyle:(int)arg1;
//- (id)initWithText:(id)arg1 andFont:(id)arg2;
@end



// Constants.

//static const float kMarginBottom = 10.0f;
static const float kMarginBottom = 0;
static NSString * const kDefaultGlyph = @"/Library/Application Support/Wu-Lock/Default/wutang.png";
static CFStringRef const kPrefsAppID = CFSTR("com.sticktron.wu-lock");

#define WU_YELLOW	[UIColor colorWithRed:1 green:205/255.0 blue:0 alpha:1]



// Globals.

static id glyphView;
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
	selectedGlyph = settings[@"SelectedGlyph"] ? settings[@"SelectedGlyph"] : kDefaultGlyph;
	style = settings[@"Style"] ? settings[@"Style"] : @"vibrantBlur";
	yOffset = settings[@"YOffset"] ? [settings[@"YOffset"] floatValue] : 0;
	noDelay = settings[@"NoDelay"] ? [settings[@"NoDelay"] boolValue] : YES;
	hideChevron = settings[@"HideChevron"] ? [settings[@"HideChevron"] boolValue] : YES;
	useCustomText = settings[@"UseCustomText"] ? [settings[@"UseCustomText"] boolValue] : YES;
	customText = settings[@"CustomText"] ? settings[@"CustomText"] : @"Protect ya neck";
	useCustomBioText = settings[@"UseCustomBioText"] ? [settings[@"UseCustomBioText"] boolValue] : YES;
	customBioText = settings[@"CustomBioText"] ? settings[@"CustomBioText"] : @"Shame on a finga";
	dimTimeout = settings[@"DimTimeout"] ? [settings[@"DimTimeout"] intValue] : 8;
	
	//DebugLog(@"Settings are now >>>");
	//DebugLogC(@"enabled=%d", enabled);
	//DebugLogC(@"selectedGlyph=%@", selectedGlyph);
	//DebugLogC(@"style=%@", style);
	//DebugLogC(@"yOffset=%f", yOffset);
	//DebugLogC(@"noDelay=%d", noDelay);
	//DebugLogC(@"hideChevron=%d", hideChevron);
	//DebugLogC(@"useCustomText=%d", useCustomText);
	//DebugLogC(@"customText=%@", customText);
	//DebugLogC(@"useCustomBioText=%d", useCustomBioText);
	//DebugLogC(@"customBioText=%@", customBioText);
	//DebugLogC(@"dimTimeout=%d", dimTimeout);
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
	if (enabled && useCustomText) {
		return customText;
	} else {
		return %orig;
	}
}
- (void)shakeSlideToUnlockTextWithCustomText:(id)arg1 {
	if (enabled && useCustomBioText) {
		%orig(customBioText);
	} else {
		%orig;
	}
}
- (void)_layoutSlideToUnlockView {
	%orig;
	
	// position the glyph based on the frame of the slide to unlock text
	// (eg. the text is lower if the music widget is onscreen)
	
	_UIGlintyStringView *slideToUnlockView = MSHookIvar<id>(self, "_slideToUnlockView");
	DebugLog(@"slideToUnlockView=%@", slideToUnlockView);
	
	if (slideToUnlockView && glyphView) {
		CGRect frame = ((UIView *)glyphView).frame;
		frame.origin.y = slideToUnlockView.superview.frame.origin.y - frame.size.height - kMarginBottom - yOffset;
		((UIView *)glyphView).frame = frame;
	}
}
%end


%hook SBLockScreenViewController
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
	if (!enabled) return %orig;
	
	if ((self = %orig)) {
		DebugLog(@"selectedGlyph=%@", selectedGlyph);
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:selectedGlyph];
		
		if (!image) {
			NSLog(@"Wu-Lock: error: glyph image not found.");
		} else {
			DebugLog(@"loaded image; size=%@; scale=%f", NSStringFromCGSize(image.size), image.scale);
			
			// custom images may not have @2x/@3x suffixes,
			// so let's convert them to screen scale
			if (image.scale != [UIScreen mainScreen].scale) {
				DebugLog(@"image scale factor doesn't match screen!");
				image = [[UIImage alloc] initWithCGImage:image.CGImage
												   scale:[UIScreen mainScreen].scale
											 orientation:UIImageOrientationUp];
				DebugLog(@"fixed image; size=%@; scale=%f", NSStringFromCGSize(image.size), image.scale);
			}
			
			glyphView = [self glyphViewForStyle:style image:image];
			[self addSubview:glyphView];
		}
	}
	return self;
}

%new(@@:@@)
- (id)glyphViewForStyle:(NSString *)style image:(UIImage *)image {
	DebugLog(@"style=%@", style);
	
	//	@"White",
	//	@"Black",
	//	@"Wu-Yellow",
	//	@"Vibrant blur (3900)", //PasscodePaddle
	//	@"Plain",
	//	@"0 - Light #1",
	//	@"1 - Dark #1",
	//	@"2 - Blur",
	//	@"2000 - ColorSample",
	//	@"2010 - UltraLight", // alert views
	//	@"2029 - LightLow",
	//	@"2030 - Dark #2", // NC
	//	@"2039 - DarkLow",
	//	@"2040 - Colored #1",
	//	@"2050 - UltraDark #1",
	//	@"2060 - AdaptiveLight", // CC
	//	@"2070 - SemiLight",
	//	@"2071 - FlatSemiLight",
	//	@"2080 - UltraColored"
	//	@"Light vibrant blur (3901)", //LightKeyboard
	
	UIView *newGlyphView;
	
	if ([style isEqualToString:@"white"] ||
		[style isEqualToString:@"black"] ||
		[style isEqualToString:@"wu-yellow"]) {
		
		// ImageView with tinted image
		newGlyphView = [[UIImageView alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
		
		if ([style isEqualToString:@"white"]) {
			newGlyphView.tintColor = UIColor.whiteColor;
		} else if ([style isEqualToString:@"black"]) {
			newGlyphView.tintColor = UIColor.blackColor;
		} else if ([style isEqualToString:@"wu-yellow"]) {
			newGlyphView.tintColor = WU_YELLOW;
		}
		
		
	} else if ([style isEqualToString:@"plain"]) {
		// ImageView with original image
		newGlyphView = [[UIImageView alloc] initWithImage:image];
		
		
	} else { // BackdropView with image mask
		
//		int code = 3900; // default setting (vibrantBlur)
//		
//		if ([style isEqualToString:@"2030"]) {
//			code = 2030;
//		} else if ([style isEqualToString:@"2039"]) {
//			code = 2039;
//		} else if ([style isEqualToString:@"2050"]) {
//			code = 2050;
//		} else if ([style isEqualToString:@"2060"]) {
//			code = 2060;
//		} else if ([style isEqualToString:@"2070"]) {
//			code = 2070;
//		} else if ([style isEqualToString:@"2071"]) {
//			code = 2071;
//		} else if ([style isEqualToString:@"2080"]) {
//			code = 2080;
//		} else if ([style isEqualToString:@"3901"]) {
//			code = 3901;
//		}
		
		int code = [style intValue];
		newGlyphView = [[_UIBackdropView alloc] initWithFrame:(CGRect){CGPointZero, image.size} style:code];
		
		// turn image into a mask
		CALayer *maskLayer = [CALayer layer];
		maskLayer.frame = newGlyphView.bounds;
		maskLayer.contents = (id)image.CGImage;
		newGlyphView.layer.mask = maskLayer;
	}
	
	// set initial position
	CGRect screenRect = [UIScreen mainScreen].bounds;
	float x = screenRect.size.width + CGRectGetMidX(screenRect);
	float y = screenRect.size.height - 110 - (image.size.height/2.0) - yOffset;
	newGlyphView.center = (CGPoint){x, y};
	
	return newGlyphView;
}


/*

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

 
 
 //		// some styles require a second layer of glyph...
 //
 //		//UIImageView *glyphImageView = [[UIImageView alloc] initWithImage:image];
 //		UIImageView *glyphImageView = [[UIImageView alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
 //		glyphImageView.tintColor = [UIColor colorWithWhite:1 alpha:0.2];
 //		[glyphImageView _setDrawsAsBackdropOverlayWithBlendMode:kCGBlendModeColorDodge];
 //
 //		//		glyphImageView.tintColor = [UIColor _vibrantDarkFillDodgeColor];
 //		//		[glyphImageView _setDrawsAsBackdropOverlayWithBlendMode:kCGBlendModeColorDodge];
 
 //		[glyphView.contentView addSubview:glyphImageView];
 //		[glyphImageView release];
 
 
 
 
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

*/


%end


%hook _UIGlintyStringView
- (id)_chevronImageForStyle:(int)arg1 {
	if (enabled && hideChevron) {
		return nil;
	} else {
		return %orig;
	}
}
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

