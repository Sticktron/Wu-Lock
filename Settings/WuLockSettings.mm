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
#define DEFAULT_IMAGES_PATH		@"/Library/Application Support/Wu-Lock"
#define USER_IMAGES_PATH			[NSHomeDirectory() stringByAppendingPathComponent:@"Media/Wu-Lock"]

#define WU_YELLOW					[UIColor colorWithRed:1 green:205/255.0 blue:0 alpha:1]
#define IRON						[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]

#define THUMBNAIL_TAG				1
#define TITLE_TAG					2
#define SUBTITLE_TAG				3



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
@property (nonatomic, strong) NSArray *defaultImages;
@property (nonatomic, strong) NSArray *userImages;
@property (nonatomic, strong) NSString *selectedImage;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSCache *imageCache;
@end


@implementation WUImageController

- (instancetype)init {
	self = [super init];
	
	if (self) {
		DebugLog0;
		
		_queue = [[NSOperationQueue alloc] init];
		_queue.maxConcurrentOperationCount = 4;
		_imageCache = [[NSCache alloc] init];
		
		_defaultImages = @[
			@{
				@"path": [DEFAULT_IMAGES_PATH stringByAppendingPathComponent:@"wu-tang"],
				@"name": @"Wu-Tang"
			},
			@{
				@"path": [DEFAULT_IMAGES_PATH stringByAppendingPathComponent:@"gza"],
				@"name": @"GZA/Genius"
			}
		];
		
		[self setTitle:@"Choose Image"];
	}
	return self;
}

- (void)loadView {
	self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
												  style:UITableViewStyleGrouped];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.rowHeight = 85.0f;
	self.view = self.tableView;
}

- (void)viewWillAppear:(BOOL)animated {
	DebugLog0;
	[super viewWillAppear:animated];
	
//	self.defaultImages = [self scanPathForImages:DEFAULT_IMAGE_PATH];
//	self.customImages = [self scanPathForImages:CUSTOM_IMAGE_PATH];
	
	[self updateUserImageList];
}


- (void)updateUserImageList {
	NSMutableArray *results = [NSMutableArray array];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSURL *url = [NSURL fileURLWithPath:USER_IMAGES_PATH isDirectory:YES];
	NSArray *keys = @[NSURLNameKey];
	NSArray *imageURLs = [fm contentsOfDirectoryAtURL:url
						   includingPropertiesForKeys:keys
											  options:NSDirectoryEnumerationSkipsHiddenFiles
												error:nil];
	DebugLog(@"Found these files here (%@) >> %@", url, imageURLs);
	
	// sort results by name
	[(NSMutableArray *)imageURLs sortUsingComparator:^(NSURL *a, NSURL *b) {
		NSDate *name1 = [[a resourceValuesForKeys:keys error:nil] objectForKey:NSURLNameKey];
		NSDate *name2 = [[b resourceValuesForKeys:keys error:nil] objectForKey:NSURLNameKey];
		return [name2 compare:name1];
	}];
	
	// process results...
	for (NSURL *imageURL in imageURLs) {
		NSString *path = [imageURL path];
		
		// check if file is an image by trying to load it
		UIImage *testImage = [UIImage imageWithContentsOfFile:[imageURL path]];
		if (!testImage) {
			// file is not an image
		} else {
			// add to results
			NSString *filename = [imageURL resourceValuesForKeys:keys error:nil][NSURLNameKey];
			[results addObject:@{ @"path":path, @"name":filename }];
		}
	}
	DebugLog(@"Results: %@", results);
	
	self.userImages = results;
}

//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Default images";
	} else {
		return @"User images";
	}
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return self.defaultImages.count;
	} else {
		return self.userImages.count;
	}
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	return 75.0f;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	static NSString *CustomCellIdentifier = @"CustomCell";
	cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
	
	if (!cell) {
		// create custom cell layout...
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:CustomCellIdentifier];
		cell.opaque = YES;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		CGRect frame;
		
		// thumbnail
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 75, 75)];
		imageView.opaque = YES;
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.tag = THUMBNAIL_TAG;
		imageView.backgroundColor = IRON;
		[cell.contentView addSubview:imageView];
		
		// title
		frame.origin = CGPointMake(100, 5);
		frame.size.width = cell.contentView.bounds.size.width - frame.origin.x;
		frame.size.height = 75.0f;
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
		titleLabel.opaque = YES;
		titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
		titleLabel.textColor = UIColor.blackColor;
		titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		titleLabel.tag = TITLE_TAG;
		[cell.contentView addSubview:titleLabel];
	}
	
	// add content to cells
	UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:THUMBNAIL_TAG];
	UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:TITLE_TAG];
	
	NSDictionary *imageInfo;
	if (indexPath.section == 0) {
		imageInfo = self.defaultImages[indexPath.row];
	} else {
		imageInfo = self.userImages[indexPath.row];
	}
	
	NSString *path = imageInfo[@"path"];
	NSString *name = imageInfo[@"name"];
	
	titleLabel.text = name;
	
	// try to get thumbnail from the cache, if not found create one...
	UIImage *thumbnail = [self.imageCache objectForKey:path];
	if (thumbnail) {
		DebugLog(@"found image in cache (%@): %@", path, thumbnail);
		imageView.image = thumbnail;
	} else {
		DebugLog(@"didn't find image in cache");
		[self.queue addOperationWithBlock:^{
			// load image
			UIImage *image = [UIImage imageWithContentsOfFile:path];
			DebugLog(@"tried to load image and got: %@", image);
			
			if (image) {
				// resize ?
				
				// add to cache
				[self.imageCache setObject:image forKey:path];
				
				// add thumbnail to cell
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
	
//	// is checked ?
//	if ([self.selectedBackground isEqualToString:background[FILE_KEY]]) {
//		cell.accessoryType = UITableViewCellAccessoryCheckmark;
//	} else {
//		cell.accessoryType = UITableViewCellAccessoryNone;
//	}
	
	return cell;
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
	//[tableView reloadData];
}

@end










