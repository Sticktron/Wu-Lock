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
#import <Preferences/PSSwitchTableCell.h>



#define HEADER_PATH		@"/Library/PreferenceBundles/WuLockSettings.bundle/header.png"

#define WU_YELLOW		[UIColor colorWithRed:1 green:205/255.0 blue:0 alpha:1]
#define GRAPE			[UIColor colorWithRed:0.5 green:0 blue:1 alpha:1]
#define IRON			[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]
#define RED				[UIColor colorWithRed:1 green:0 blue:0 alpha:1]

#define URL_EMAIL				@"mailto:sticktron@hotmail.com"
#define URL_WEBSITE				@"http://sticktron.com"
#define URL_GITHUB				@"http://github.com/Sticktron/"
#define URL_REDDIT				@"http://reddit.com/r/jailbreak"

#define URL_TWITTER_APP			@"twitter://user?screen_name=sticktron"
#define URL_TWITTER_WEB			@"http://twitter.com/sticktron"
#define URL_TWEETBOT			@"tweetbot:///user_profile/sticktron"
#define URL_TWITTERRIFIC		@"twitterrific:///profile?screen_name=sticktron"
#define URL_TWEETINGS			@"tweetings:///user?screen_name=sticktron"


// Header cell.

@interface WULogoCell : PSTableCell
@property (nonatomic, strong) UIImageView *logoView;
@end

@implementation WULogoCell
- (id)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:@"LogoCell"
					  specifier:specifier];
	
	if (self) {
		self.backgroundColor = UIColor.blackColor;
		
		UIImage *logo = [[UIImage alloc] initWithContentsOfFile:HEADER_PATH];
		_logoView = [[UIImageView alloc] initWithImage:logo];
		[self addSubview:_logoView];
	}
	
	return self;
}
- (CGFloat)preferredHeightForWidth:(CGFloat)height {
	return 150.0f;
}
- (void)layoutSubviews {
	[super layoutSubviews];
	self.logoView.center = self.center;
}
@end



// Enabled switch.

@interface WUSwitchCell : PSSwitchTableCell
@end

@implementation WUSwitchCell
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
	self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
	if (self) {
		[((UISwitch *)[self control]) setOnTintColor:WU_YELLOW];
	}
	return self;
}
@end



// Button cells

@interface WUButtonCell : PSTableCell
@end

@implementation WUButtonCell
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
	self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
	if (self) {
		[[self titleLabel] setTextColor:WU_YELLOW];
		[[self titleTextLabel] setTextColor:WU_YELLOW];
	}
	return self;
}
- (void)layoutSubviews {
	[super layoutSubviews];
	[self.textLabel setTextColor:UIColor.blackColor];
}
@end







// Settings controller.

@interface WuLockSettingsController : PSListController
@end

@implementation WuLockSettingsController

- (id)initForContentSize:(CGSize)size {
	DebugLog0;
	
	self = [super initForContentSize:size];
	if (self) {
		// add a Respring button to the navbar
		UIBarButtonItem *respringButton = [[UIBarButtonItem alloc]
										   initWithTitle:@"Respring"
										   style:UIBarButtonItemStyleDone
										   target:self
										   action:@selector(showRespringAlert)];
		
		respringButton.tintColor = WU_YELLOW;
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

//
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

//
- (void)openEmail {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_EMAIL]];
}

- (void)openTwitter {
	NSURL *url;
	
	// try TweetBot
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		url = [NSURL URLWithString:URL_TWEETBOT];
		
	// try Twitterrific
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		url = [NSURL URLWithString:URL_TWITTERRIFIC];
	
	// try Tweetings
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
		url = [NSURL URLWithString:URL_TWEETINGS];
		
	// try Twitter
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		url = [NSURL URLWithString:URL_TWITTER_APP];
		
	// use Safari
	} else {
		url = [NSURL URLWithString:URL_TWITTER_WEB];
	}
	
	[[UIApplication sharedApplication] openURL:url];
}

- (void)openWebsite {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_WEBSITE]];
}

- (void)openGitHub {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_GITHUB]];
}

- (void)openReddit {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_REDDIT]];
}

@end



