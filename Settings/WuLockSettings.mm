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



#define HEADER_PATH				@"/Library/PreferenceBundles/WuLockSettings.bundle/header.png"
#define USER_IMAGE_PATH			@"/Library/Application Support/WuLock/custom"
#define DEFAULT_IMAGE_PATH		@"/Library/Application Support/WuLock/default"

#define WU_YELLOW		[UIColor colorWithRed:1 green:205/255.0 blue:0 alpha:1]
#define GRAPE			[UIColor colorWithRed:0.5 green:0 blue:1 alpha:1]
#define IRON			[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]



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



// Button cells.

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
	[self.textLabel setTextColor:IRON];
}
@end




// Main controller.

@interface WuLockSettingsController : PSListController
@end

@implementation WuLockSettingsController

- (id)initForContentSize:(CGSize)size {
	DebugLog0;
	
	self = [super initForContentSize:size];
	if (self) {
		
//		// add a Respring button to the navbar
//		UIBarButtonItem *respringButton = [[UIBarButtonItem alloc]
//										   initWithTitle:@"Respring"
//										   style:UIBarButtonItemStyleDone
//										   target:self
//										   action:@selector(showRespringAlert)];
//		
//		respringButton.tintColor = WU_YELLOW;
//		[self.navigationItem setRightBarButtonItem:respringButton];
		
	}
	
	return self;
}

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"WuLockSettings" target:self];
	}
	return _specifiers;
}

/*
- (void)setEnabledWithAlert:(id)value specifier:(id)specifier {
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
*/

- (void)openEmail {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:sticktron@hotmail.com"]];
}
- (void)openGitHub {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/Sticktron/"]];
}
- (void)openWebsite {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.sticktron.com"]];
}
- (void)openWikipedia {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.wikipedia.org/wiki/Wu-Tang_Clan"]];
}
- (void)openReddit {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://reddit.com/r/jailbreak"]];
}

- (void)openTwitter {
	NSURL *url;
	
	// try TweetBot
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		url = [NSURL URLWithString:@"tweetbot:///user_profile/sticktron"];
		
	// try Twitterrific
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		url = [NSURL URLWithString:@"twitterrific:///profile?screen_name=sticktron"];
		
	// try Tweetings
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
		url = [NSURL URLWithString:@"tweetings:///user?screen_name=sticktron"];
		
	// try Twitter
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		url = [NSURL URLWithString:@"twitter://user?screen_name=sticktron"];
		
	// else use Safari
	} else {
		url = [NSURL URLWithString:@"http://twitter.com/sticktron"];
	}
	
	[[UIApplication sharedApplication] openURL:url];
}

@end



// Image chooser.

@interface WUImageController : PSViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *defaultImages;
@property (nonatomic, strong) NSMutableArray *userImages;
@property (nonatomic, strong) NSString *selectedImage;

@end


@implementation WUImageController

- (instancetype)init {
	self = [super init];
	
	if (self) {
		DebugLog0;
		
		_defaultImages = [NSMutableArray arrayWithObjects:@"test", nil];
		_userImages = [NSMutableArray arrayWithObjects:@"test2", nil];
		
		[self setTitle:@"Choose Image"];
	}
	return self;
}

- (void)loadView {
	self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
												  style:UITableViewStyleGrouped];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.rowHeight = 44.0f;
	
	self.view = self.tableView;
}

- (void)viewWillAppear:(BOOL)animated {
	DebugLog0;
	[super viewWillAppear:animated];
	[self scanForMedia];
}

- (void)scanForMedia {
	DebugLog0;
	
	// reset the lists
//	self.defaultImages = nil;
//	self.defaultImages = [NSMutableArray array];
//	self.userImages = nil;
//	self.userImages = [NSMutableArray array];
	
	// scan filesystem
	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *keys = @[NSURLContentModificationDateKey, NSURLFileSizeKey, NSURLNameKey];
	
	// default image set
	NSURL *url = [NSURL fileURLWithPath:DEFAULT_IMAGE_PATH isDirectory:YES];
	NSArray *defaultImages = (NSMutableArray *)[fm contentsOfDirectoryAtURL:url
												 includingPropertiesForKeys:keys
																	options:NSDirectoryEnumerationSkipsHiddenFiles
																	  error:nil];
	DebugLog(@"Default images (%@): %@", url, defaultImages);
	
	// sort by name
//	[backgrounds sortUsingComparator:^(NSURL *a, NSURL *b) {
//		NSDate *date1 = [[a resourceValuesForKeys:keys error:nil] objectForKey:NSURLContentModificationDateKey];
//		NSDate *date2 = [[b resourceValuesForKeys:keys error:nil] objectForKey:NSURLContentModificationDateKey];
//		return [date2 compare:date1];
//	}];
	
//	// add files to list
//	for (NSURL *bgURL in backgrounds) {
//		if ([UIImage imageWithContentsOfFile:[bgURL path]]) {
//			NSString *file = [bgURL resourceValuesForKeys:keys error:nil][NSURLNameKey];
//			NSString *size = [bgURL resourceValuesForKeys:keys error:nil][NSURLFileSizeKey];
//			
//			if ([size floatValue] < 1024*1024) { // < 1MB
//				size = [NSString stringWithFormat:@"%.0f KB", [size floatValue] / 1024.0f];
//			} else {
//				size = [NSString stringWithFormat:@"%.1f MB", [size floatValue] / 1024.0f / 1024.f];
//			}
//			
//			[self.backgrounds addObject:@{ FILE_KEY: file, SIZE_KEY: size }];
//		} else {
//			// unsupported image
//		}
//	}
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title;
	switch (section) {
		case 0: title = @"Default images";
			break;
		case 1: title = @"User images";
			break;
	}
	return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger num;
	switch (section) {
		case 0: num = self.defaultImages.count;
			break;
		case 1: num = self.userImages.count;
			break;
	}
	return num;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(@"User selected row: %ld, section: %ld", (long)indexPath.row, (long)indexPath.section);
	
	
	/*
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
		//
		// de-selected the selected row
		//
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		if (indexPath.section == VIDEO_SECTION) {
			self.selectedVideo = ID_NONE;
		} else {
			self.selectedBackground = ID_NONE;
		}
		
	} else {
		//
		// selected a new row
		//
		
		// uncheck old selection
		for (NSInteger i = 0; i < [tableView numberOfRowsInSection:indexPath.section]; i++) {
			NSIndexPath	 *path = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:path];
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		
		// check new selection
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		
		// get the file name
		UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:TITLE_TAG];
		
		// save selection
		if (indexPath.section == VIDEO_SECTION) {
			if (indexPath.row == 0) {
				self.selectedVideo = ID_DEFAULT;
			} else {
				self.selectedVideo = titleLabel.text;
			}
			DebugLog(@"selected video: %@", self.selectedVideo);
			
		} else if (indexPath.section == BACKGROUND_SECTION) {
			if (indexPath.row == 0) {
				self.selectedBackground = ID_DEFAULT;
			} else {
				self.selectedBackground = titleLabel.text;
			}
			DebugLog(@" selected background: %@", self.selectedBackground);
		}
	}
	*/
	
	//[self savePrefs:YES];
	[tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	//
	// media item cell
	//
	static NSString *CustomCellIdentifier = @"CustomCell";
	cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									  reuseIdentifier:CustomCellIdentifier];
		cell.opaque = YES;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
//		// thumbnail
//		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0f, 2.0f, 40.0f, 40.0f)];
//		imageView.opaque = YES;
//		imageView.contentMode = UIViewContentModeScaleAspectFit;
//		imageView.tag = THUMBNAIL_TAG;
//		[cell.contentView addSubview:imageView];
//		
//		// title
//		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, 10.0f, 215.0f, 16.0f)];
//		titleLabel.opaque = YES;
//		titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
//		titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
//		titleLabel.tag = TITLE_TAG;
//		[cell.contentView addSubview:titleLabel];
//		
//		// subtitle
//		UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, 28.0f, 215.0f, 12.0f)];
//		subtitleLabel.opaque = YES;
//		subtitleLabel.font = [UIFont italicSystemFontOfSize:10.0];
//		subtitleLabel.textColor = [UIColor grayColor];
//		subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
//		subtitleLabel.tag = SUBTITLE_TAG;
//		[cell.contentView addSubview:subtitleLabel];
	}
	
	/*
	UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:THUMBNAIL_TAG];
	UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:TITLE_TAG];
	UILabel *subtitleLabel = (UILabel *)[cell.contentView viewWithTag:SUBTITLE_TAG];
	
	if (indexPath.section == VIDEO_SECTION) {
		NSDictionary *video = self.videos[indexPath.row];
		
		if (indexPath.row == 0) {
			//
			// Default video
			//
			titleLabel.text = DEFAULT_VIDEO_TITLE;
			subtitleLabel.text = @"*Default";
			NSString *path = [NSString stringWithFormat:@"%@/%@", DEFAULT_PATH, DEFAULT_VIDEO_THUMB];
			imageView.image = [UIImage imageWithContentsOfFile:path];
			
			// checked ?
			if ([self.selectedVideo isEqualToString:ID_DEFAULT]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			
		} else {
			//
			// User video
			//
			NSString *filename = video[FILE_KEY];
			titleLabel.text = filename;
			subtitleLabel.text = video[SIZE_KEY];
			
			// get thumbnail from cache, or else load and cache it in the background...
			
			UIImage *thumbnail = [self.imageCache objectForKey:filename];
			
			if (thumbnail) {
				imageView.image = thumbnail;
				
			} else {
				[self.queue addOperationWithBlock:^{
					// load
					UIImage *image = [self thumbnailForVideo:filename withMaxSize:imageView.bounds.size];
					
					if (image) {
						// add to cache
						[self.imageCache setObject:image forKey:filename];
						
						// update UI on the main thread
						[[NSOperationQueue mainQueue] addOperationWithBlock:^{
							UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
							
							if (cell) {
								UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:THUMBNAIL_TAG];
								imageView.image = image;
							}
						}];
					}
				}];
			}
			
			// checked ?
			if ([self.selectedVideo isEqualToString:video[FILE_KEY]]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
		
	} else if (indexPath.section == BACKGROUND_SECTION) {
		NSDictionary *background = self.backgrounds[indexPath.row];
		
		if (indexPath.row == 0) {
			//
			// Default background
			//
			titleLabel.text = DEFAULT_BG_TITLE;
			subtitleLabel.text = @"*Default";
			NSString *path = [NSString stringWithFormat:@"%@/%@", DEFAULT_PATH, DEFAULT_BG_THUMB];
			imageView.image = [UIImage imageWithContentsOfFile:path];
			
			// checked ?
			if ([self.selectedBackground isEqualToString:ID_DEFAULT]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			
		} else {
			//
			// Custom background
			//
			NSString *filename = background[FILE_KEY];
			titleLabel.text = filename;
			subtitleLabel.text = background[SIZE_KEY];
			
			// get thumbnail from cache, or else load and cache it in the background...
			
			UIImage *thumbnail = [self.imageCache objectForKey:filename];
			
			if (thumbnail) {
				imageView.image = thumbnail;
				
			} else {
				[self.queue addOperationWithBlock:^{
					// load
					NSString *path = [NSString stringWithFormat:@"%@/%@", USER_BGS_PATH, filename];
					UIImage *image = [UIImage imageWithContentsOfFile:path];
					
					if (image) {
						image = [UIImage imageWithImage:image scaledToMaxWidth:imageView.bounds.size.height
											  maxHeight:imageView.bounds.size.height];
						
						// add to cache
						[self.imageCache setObject:image forKey:filename];
						
						// update UI on main thread
						[[NSOperationQueue mainQueue] addOperationWithBlock:^{
							UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
							
							if (cell) {
								UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:THUMBNAIL_TAG];
								imageView.image = image;
							}
						}];
					}
				}];
			}
			
			// is checked ?
			if ([self.selectedBackground isEqualToString:background[FILE_KEY]]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
	}
	*/
	
	return cell;
}

@end










