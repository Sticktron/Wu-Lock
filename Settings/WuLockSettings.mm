//
//  Wu-Lock Settings
//
//  Created by Sticktron.
//  Copyright (c) 2014. All rights reserved.
//
//

#define DEBUG_PREFIX @"Wu-Lock"
#import "../DebugLog.h"

#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>



#define HEADER_PATH		@"/Library/PreferenceBundles/WuLockSettings.bundle/header.png"
#define GRAPE_COLOR		[UIColor colorWithRed:0.5 green:0 blue:1 alpha:1];


//static id controller = nil;



// Header cell.

@interface WLLogoCell : PSTableCell
@property (nonatomic, strong) UIImageView *logoView;
@end

@implementation WLLogoCell
- (id)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:@"LogoCell"
					  specifier:specifier];
	
	if (self) {
		self.backgroundColor = GRAPE_COLOR;
		
		UIImage *logo = [[UIImage alloc] initWithContentsOfFile:HEADER_PATH];
		_logoView = [[UIImageView alloc] initWithImage:logo];
		[self addSubview:_logoView];
		
	}
	
	return self;
}
- (CGFloat)preferredHeightForWidth:(CGFloat)height {
	return 120.0f;
}
- (void)layoutSubviews {
	[super layoutSubviews];
	self.logoView.center = self.center;
}
@end



// Settings controller.

@interface WuLockSettingsController : PSListController
- (void)setEnabledWithAlert:(id)value specifier:(id)specifier;
- (void)showRespringAlert;
- (void)respring;
@end

@implementation WuLockSettingsController

- (id)initForContentSize:(CGSize)size {
	DebugLog0;
	
	self = [super initForContentSize:size];
	if (self) {
		//controller = self;
		
		// add a Respring button to the navbar
		UIBarButtonItem *respringButton = [[UIBarButtonItem alloc]
										   initWithTitle:@"Respring"
										   style:UIBarButtonItemStyleDone
										   target:self
										   action:@selector(showRespringAlert)];
		
		respringButton.tintColor = GRAPE_COLOR;
		[self.navigationItem setRightBarButtonItem:respringButton];
	}
	
	return self;
}

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"WuLockSettings" target:self];
	}
	return _specifiers;
}

- (void)setEnabledWithAlert:(id)value specifier:(id)specifier {
	DebugLog(@"setting value:%@ for Enabled", value);
	
	[self setPreferenceValue:value specifier:specifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self showRespringAlert];
}

- (void)showRespringAlert {
	UIAlertView *alert = [[UIAlertView alloc]
			  initWithTitle:@"Restart SpringBoard?"
					message:@"SpringBoard must be restarted to enable or disable the tweak."
				   delegate:self
		  cancelButtonTitle:@"Later"
		  otherButtonTitles:@"Now", nil];
	
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(int)buttonIndex {
	if (buttonIndex == 1) {
		[self respring];
	}
}

- (void)respring {
	NSLog(@"Wu-Lock called for a respring.");
	
	// this function is deprecated !!!
	system("killall -HUP SpringBoard");
}

@end



