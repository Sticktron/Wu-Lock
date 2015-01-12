//
//  Wu-Lock Settings
//
//  Created by Sticktron.
//  Copyright (c) 2015. All rights reserved.
//
//

#define DEBUG_PREFIX @"[Wu-Lock Prefs]"
#import "../DebugLog.h"

#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSwitchTableCell.h>


#define HEADER_PATH					@"/Library/PreferenceBundles/Wu-Lock.bundle/header.png"
#define TILE_BG_PATH				@"/Library/PreferenceBundles/Wu-Lock.bundle/tile.png"
#define DEFAULT_IMAGES_PATH			@"/Library/Application Support/Wu-Lock/Default"
#define USER_IMAGES_PATH			@"/Library/Application Support/Wu-Lock/Custom"

#define WU_YELLOW					[UIColor colorWithRed:1 green:205/255.0 blue:0 alpha:1]
#define IRON						[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]

#define THUMBNAIL_TAG				1
#define TITLE_TAG					2

#define PREFS_APPID					CFSTR("com.sticktron.wu-lock")
#define PREFS_GLYPH_KEY				CFSTR("SelectedGlyph")

#define DEFAULT_GLYPH				@"/Library/Application Support/Wu-Lock/Default/wutang.png"


static NSString *selectedGlyph;



// Helpers.

@implementation UIImage (Private)

// Resize UIImage to new dimensions.
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
	DebugLogC(@"resizing image (%@) to size: (%fx%f)", image, size.width, size.height);
	
	BOOL opaque = NO;
	
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		// In next line, pass 0.0 to use the current device's pixel scaling factor.
		// Pass 1.0 to force exact pixel size.
		UIGraphicsBeginImageContextWithOptions(size, opaque, 0);
	} else {
		UIGraphicsBeginImageContext(size);
	}
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

// Resize UIImage to fit within new dimensions.
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFitSize:(CGSize)size {
	DebugLogC(@"resizing image (%@) to fit box: (%fx%f)", image, size.width, size.height);
	
	CGFloat oldWidth = image.size.width;
	CGFloat oldHeight = image.size.height;
	
	CGFloat scaleFactor = (oldWidth > oldHeight) ? size.width / oldWidth : size.height / oldHeight;
	CGSize newSize = CGSizeMake(oldWidth * scaleFactor, oldHeight * scaleFactor);
	
	return [self imageWithImage:image scaledToSize:newSize];
}

@end



// Custom Table Cells.

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
	return 130.0f;
}
- (void)layoutSubviews {
	[super layoutSubviews];
	self.logoView.center = self.center;
}
@end

//

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

//

@interface WUButtonCell : PSTableCell
@end

@implementation WUButtonCell
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
	self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
	if (self) {
		//
	}
	return self;
}
- (void)layoutSubviews {
	[super layoutSubviews];
	[self.textLabel setTextColor:IRON];
}
@end

//

@interface WULinkCell : PSTableCell
@property (nonatomic, strong) UIImageView *thumbnailView;
@property (nonatomic, strong) NSString *lastSelectedGlyph;
- (void)updateThumbnail;
@end

@implementation WULinkCell
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
	self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
	if (self) {
		//imageChooserCell = self;
		
		_thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 40, 40)];
		_thumbnailView.opaque = YES;
		_thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
		[self.contentView addSubview:_thumbnailView];
	}
	return self;
}
- (void)layoutSubviews {
	[super layoutSubviews];
	
	// adjust image position
	CGRect frame = self.thumbnailView.frame;
	frame.origin.x = self.contentView.bounds.size.width - frame.size.width - 2;
	self.thumbnailView.frame = frame;
	
	// update image if necessary
	[self updateThumbnail];
}
- (void)updateThumbnail {
	if (![selectedGlyph isEqualToString:self.lastSelectedGlyph]) {
		UIImage *image = [UIImage imageWithContentsOfFile:selectedGlyph];
		DebugLog(@"updating thumbnail for selected image (%@): %@", selectedGlyph, image);
		
		self.thumbnailView.image = image;
	}
}
@end



// Main Controller.

@interface WuLockSettingsController : PSListController
@end

@implementation WuLockSettingsController
- (id)initForContentSize:(CGSize)size {
	DebugLog0;
	
	self = [super initForContentSize:size];
	if (self) {
		// load user setting for selected glyph
		CFPreferencesAppSynchronize(PREFS_APPID);
		CFPropertyListRef value = CFPreferencesCopyAppValue(PREFS_GLYPH_KEY, PREFS_APPID);
		
		selectedGlyph = (__bridge NSString *)value;
		DebugLog(@"checked prefs for selectedGlyph and got: %@", selectedGlyph);
		
		if (!selectedGlyph) {
			DebugLog(@"using default glyph");
			selectedGlyph = DEFAULT_GLYPH;
		}
		
		
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
- (void)openGitHub {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/Sticktron/"]];
}
- (void)openSticktronWeb {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.sticktron.com"]];
}
- (void)openReddit {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://reddit.com/r/jailbreak"]];
}
- (void)openWikipedia {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.wikipedia.org/wiki/Wu-Tang_Clan"]];
}
- (void)openWuTangClanWeb {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.wutangclan.com"]];
}
@end



// Image Chooser.

@interface WUImageController : PSViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *defaultImages;
@property (nonatomic, strong) NSArray *userImages;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) NSIndexPath *checkedIndexPath;
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
				@"path": [DEFAULT_IMAGES_PATH stringByAppendingPathComponent:@"w.png"],
				@"name": @"W"
			},
			@{
				@"path": [DEFAULT_IMAGES_PATH stringByAppendingPathComponent:@"wutang.png"],
				@"name": @"Wu-Tang"
			},
			@{
				@"path": [DEFAULT_IMAGES_PATH stringByAppendingPathComponent:@"wutangclan.png"],
				@"name": @"Wu-Tang Clan"
			},
			@{
				@"path": [DEFAULT_IMAGES_PATH stringByAppendingPathComponent:@"gza.png"],
				@"name": @"GZA/Genius"
			},
			@{
				@"path": [DEFAULT_IMAGES_PATH stringByAppendingPathComponent:@"rza.png"],
				@"name": @"RZA"
			},
			@{
				@"path": [DEFAULT_IMAGES_PATH stringByAppendingPathComponent:@"raekwon.png"],
				@"name": @"Raekwon"
			},
			@{
				@"path": [DEFAULT_IMAGES_PATH stringByAppendingPathComponent:@"ugod.png"],
				@"name": @"U-God"
			},
			@{
				@"path": [DEFAULT_IMAGES_PATH stringByAppendingPathComponent:@"methodman.png"],
				@"name": @"Method Man"
			},
			@{
				@"path": [DEFAULT_IMAGES_PATH stringByAppendingPathComponent:@"methodman2.png"],
				@"name": @"Method Man"
			},
			@{
				@"path": [DEFAULT_IMAGES_PATH stringByAppendingPathComponent:@"mastakilla.png"],
				@"name": @"Masta Killa"
			},
			@{
				@"path": [DEFAULT_IMAGES_PATH stringByAppendingPathComponent:@"ins.png"],
				@"name": @"Inspectah Deck"
			},
			@{
				@"path": [DEFAULT_IMAGES_PATH stringByAppendingPathComponent:@"odb.png"],
				@"name": @"Ol' Dirty Bastard"
			},
			@{
				@"path": [DEFAULT_IMAGES_PATH stringByAppendingPathComponent:@"ghostface.png"],
				@"name": @"Ghostface Killah"
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
	self.tableView.rowHeight = 74.0f;
	self.view = self.tableView;
}
- (void)viewWillAppear:(BOOL)animated {
	DebugLog0;
	[self updateUserImageList];
	[super viewWillAppear:animated];
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
		
		// thumbnail
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 64, 64)];
		imageView.opaque = YES;
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		UIImage *bgTile = [UIImage imageWithContentsOfFile:TILE_BG_PATH];
		imageView.backgroundColor = [UIColor colorWithPatternImage:bgTile];
		imageView.tag = THUMBNAIL_TAG;
		[cell.contentView addSubview:imageView];
		
		// title
		CGRect frame = CGRectMake(94, 5, cell.contentView.bounds.size.width - 94, 64);
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
		titleLabel.opaque = YES;
		titleLabel.font = [UIFont boldSystemFontOfSize:16];
		titleLabel.textColor = UIColor.blackColor;
		titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		titleLabel.tag = TITLE_TAG;
		[cell.contentView addSubview:titleLabel];
	}
	
	// add content to cells...
	
	NSDictionary *imageInfo;
	if (indexPath.section == 0) {
		imageInfo = self.defaultImages[indexPath.row];
	} else {
		imageInfo = self.userImages[indexPath.row];
	}
	
	UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:TITLE_TAG];
	titleLabel.text = imageInfo[@"name"];
	
	UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:THUMBNAIL_TAG];
	
	// get thumbnail from cache, or create and cache new one...
	NSString *path = imageInfo[@"path"];
	UIImage *thumbnail = [self.imageCache objectForKey:path];
	
	if (thumbnail) {
		// found image in cache
		DebugLog(@"found image in cache for path: %@", path);
		imageView.image = thumbnail;
		
	} else {
		// image is not yet cached
		DebugLog(@"no image in cache, loading now...");
		
		[self.queue addOperationWithBlock:^{
			UIImage *image = [UIImage imageWithContentsOfFile:path];
			if (image) {
				// create thumbnail
				CGSize size = imageView.frame.size;
				UIImage *thumb = [UIImage imageWithImage:image scaledToFitSize:size];
				DebugLog(@"created thumbnail: %@", thumb);
				
				// add to cache
				[self.imageCache setObject:thumb forKey:path];
				DebugLog(@"cached with key: %@", path);
				
				// display in cell
				[[NSOperationQueue mainQueue] addOperationWithBlock:^{
					UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
					if (cell) {
						UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:THUMBNAIL_TAG];
						imageView.image = thumb;
					}
				}];
			} else {
				// image not found
				DebugLog(@"error: can't create thumbnail, image not found at path: %@", path);
			}
		}];
	}
	
	// do we know which row should be checked?
	if (!self.checkedIndexPath) {
		// not yet; is it this row?
		if ([path isEqualToString:selectedGlyph]) {
			self.checkedIndexPath = indexPath;
		}
	}
	
	if ([indexPath isEqual:self.checkedIndexPath]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
		 
//	if ([selectedGlyph isEqualToString:path]) {
//		cell.accessoryType = UITableViewCellAccessoryCheckmark;
//	} else {
//		cell.accessoryType = UITableViewCellAccessoryNone;
//	}
	
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(@"User selected cell at position: (%ld,%ld)", (long)indexPath.section, (long)indexPath.row);
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
		// cell is already selected
		DebugLog(@"already selected");
	} else {
		// un-check previously checked cell
		DebugLog(@"un-select currently checked cell: %@", self.checkedIndexPath);
		UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.checkedIndexPath];
		oldCell.accessoryType = UITableViewCellAccessoryNone;
		
		// check this cell
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		self.checkedIndexPath = indexPath;
		
		
//		// select this cell
//		[tableView selectRowAtIndexPath:indexPath
//									animated:NO
//							  scrollPosition:UITableViewScrollPositionNone];
		
		
		
		// get the image info
		NSDictionary *imageInfo;
		if (indexPath.section == 0) {
			imageInfo = self.defaultImages[indexPath.row];
		} else {
			imageInfo = self.userImages[indexPath.row];
		}
		
		// save selection
		selectedGlyph = imageInfo[@"path"];
		DebugLog(@"selected image: %@", selectedGlyph);
		CFPreferencesSetAppValue(PREFS_GLYPH_KEY, (CFStringRef)selectedGlyph, PREFS_APPID);
		CFPreferencesAppSynchronize(PREFS_APPID);
		
		// notify tweak
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
											 CFSTR("com.sticktron.wu-lock.settingschanged"),
											 NULL, NULL, true);
		
		//[tableView reloadData];
	}
}
@end

