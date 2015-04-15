//
//  Wu-Lock Settings
//
//  Created by Sticktron.
//  Copyright (c) 2015. All rights reserved.
//
//

#define DEBUG_PREFIX @"🍋  [Wu-Lock Prefs]"
#import "../DebugLog.h"

#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSwitchTableCell.h>
#import <Social/Social.h>


#define WU_YELLOW					[UIColor colorWithRed:1 green:205/255.0 blue:0 alpha:1]
#define IRON						[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]

#define THUMBNAIL_TAG				1
#define TITLE_TAG					2

static CFStringRef const kAppID = CFSTR("com.sticktron.wu-lock");
static CFStringRef const kSelectedGlyphKey = CFSTR("SelectedGlyph");

static NSString * const kDefaultGlyph = @"/Library/Application Support/Wu-Lock/Default/wutang.png";
static NSString * const kDefaultImagesPath = @"/Library/Application Support/Wu-Lock/Default";
static NSString * const kUserImagesPath = @"/Library/Application Support/Wu-Lock/Custom";


static NSString *selectedGlyph;


@implementation UIImage (Private)

// Scale image to size
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
	DebugLogC(@"resizing image (%.2f x .2%f) >>>>> %.2f x .2%f", image.size.width, image.size.height, size.width, size.height);
	
	UIGraphicsBeginImageContextWithOptions(size, NO, 0);
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

// Scale image to fit to size
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFitSize:(CGSize)size {
	DebugLogC(@"resizing image (%.2f x .2%f) to fit size: %.2f x .2%f", image.size.width, image.size.height, size.width, size.height);
	
	CGFloat oldWidth = image.size.width;
	CGFloat oldHeight = image.size.height;
	
	// use longest side to determine scale factor
	CGFloat scaleFactor = (oldWidth > oldHeight) ? size.width / oldWidth : size.height / oldHeight;
	
	return [self imageWithImage:image scaledToSize:CGSizeMake(oldWidth * scaleFactor, oldHeight * scaleFactor)];
}

@end



// Custom Table Cells.

@interface WULogoCell : PSTableCell
@end

@implementation WULogoCell
- (id)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:@"LogoCell"
					  specifier:specifier];
	
	if (self) {
		self.backgroundColor = UIColor.blackColor;
		
		NSString *path = @"/Library/PreferenceBundles/Wu-Lock.bundle/header.png";
		UIImage *logo = [UIImage imageWithContentsOfFile:path];
		
		UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
		logoView.frame = self.contentView.bounds;
		logoView.contentMode = UIViewContentModeCenter;
		logoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		[self.contentView addSubview:logoView];
	}
	return self;
}
- (CGFloat)preferredHeightForWidth:(CGFloat)height {
	return 130.0f;
}
@end



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



@interface WUButtonCell : PSTableCell
@end

@implementation WUButtonCell
- (void)layoutSubviews {
	[super layoutSubviews];
	
	// if I do this at init it doesn't stick :(
	[self.textLabel setTextColor:IRON];
}
@end



@interface WULinkCell : PSTableCell
@property (nonatomic, strong) UIImageView *thumbnailView;
@property (nonatomic, strong) NSString *lastSelectedGlyph;
- (void)updateThumbnail;
@end

@implementation WULinkCell
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
	self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
	if (self) {
		_thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 38, 38)];
		_thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
		[self.contentView addSubview:_thumbnailView];
	}
	return self;
}
- (void)layoutSubviews {
	[super layoutSubviews];
	
	// adjust image position
	CGRect frame = self.thumbnailView.frame;
	frame.origin.x = self.contentView.bounds.size.width - frame.size.width - 4;
	frame.origin.y = (self.bounds.size.height - frame.size.height) / 2;
	self.thumbnailView.frame = frame;
	
	// I think this is a lazy place to do this, but it will do for now
	[self updateThumbnail];
}
- (void)updateThumbnail {
	if ([selectedGlyph isEqualToString:self.lastSelectedGlyph]) {
		DebugLog(@"update not necessary");
	} else {
		UIImage *image = [UIImage imageWithContentsOfFile:selectedGlyph];
		self.thumbnailView.image = image;
		DebugLog(@"updated thumbnail to: %@", selectedGlyph);
	}
}
@end



// Settings Controller.

@interface WuLockSettingsController : PSListController
@end

@implementation WuLockSettingsController
- (id)initForContentSize:(CGSize)size {
	self = [super initForContentSize:size];
	if (self) {
		// load user setting for selected glyph
		CFPreferencesAppSynchronize(kAppID);
		CFPropertyListRef value = CFPreferencesCopyAppValue(kSelectedGlyphKey, kAppID);
		selectedGlyph = (__bridge NSString *)value;
		DebugLog(@"checked prefs for selectedGlyph and got: %@", selectedGlyph);
		
		if (!selectedGlyph) {
			DebugLog(@"using default glyph");
			selectedGlyph = kDefaultGlyph;
		}
	}
	return self;
}
- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Wu-Lock" target:self];
	}
	return _specifiers;
}
- (void)viewDidLoad {
	[super viewDidLoad];
	
	// add a heart button to the navbar
	NSString *path = @"/Library/PreferenceBundles/Wu-Lock.bundle/heart.png";
	UIImage *heartImage = [[UIImage alloc] initWithContentsOfFile:path];
	
	UIBarButtonItem *heartButton = [[UIBarButtonItem alloc] initWithImage:heartImage
																	style:UIBarButtonItemStylePlain
																   target:self
																   action:@selector(showLove)];
	heartButton.imageInsets = (UIEdgeInsets){2, 0, -2, 0};
	heartButton.tintColor = WU_YELLOW;
	
	[self.navigationItem setRightBarButtonItem:heartButton];
}
- (void)openEmail {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:sticktron@hotmail.com"]];
}
- (void)openTwitter {
	NSURL *url;
	
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		url = [NSURL URLWithString:@"tweetbot:///user_profile/sticktron"];
		
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		url = [NSURL URLWithString:@"twitterrific:///profile?screen_name=sticktron"];
		
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
		url = [NSURL URLWithString:@"tweetings:///user?screen_name=sticktron"];
		
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		url = [NSURL URLWithString:@"twitter://user?screen_name=sticktron"];
		
	} else {
		url = [NSURL URLWithString:@"http://twitter.com/sticktron"];
	}
	
	[[UIApplication sharedApplication] openURL:url];
}
- (void)openGitHub {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/Sticktron/Wu-Lock"]];
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
- (void)showLove {
	// send a nice tweet ;)
	
	SLComposeViewController *composeController = [SLComposeViewController
												  composeViewControllerForServiceType:SLServiceTypeTwitter];
	
	[composeController setInitialText:@"I'm using #Wu-Lock by @Sticktron to customize my unlock style!"];
	
	[self presentViewController:composeController
					   animated:YES
					 completion:nil];
}
@end



// Image Selecta.

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
				@"path": [kDefaultImagesPath stringByAppendingPathComponent:@"w.png"],
				@"name": @"W"
			},
			@{
				@"path": [kDefaultImagesPath stringByAppendingPathComponent:@"wutang.png"],
				@"name": @"Wu-Tang"
			},
			@{
				@"path": [kDefaultImagesPath stringByAppendingPathComponent:@"wutangclan.png"],
				@"name": @"Wu-Tang Clan"
			},
			@{
				@"path": [kDefaultImagesPath stringByAppendingPathComponent:@"gza.png"],
				@"name": @"GZA/Genius"
			},
			@{
				@"path": [kDefaultImagesPath stringByAppendingPathComponent:@"rza.png"],
				@"name": @"RZA"
			},
			@{
				@"path": [kDefaultImagesPath stringByAppendingPathComponent:@"raekwon.png"],
				@"name": @"Raekwon"
			},
			@{
				@"path": [kDefaultImagesPath stringByAppendingPathComponent:@"ugod.png"],
				@"name": @"U-God"
			},
			@{
				@"path": [kDefaultImagesPath stringByAppendingPathComponent:@"methodman.png"],
				@"name": @"Method Man"
			},
			@{
				@"path": [kDefaultImagesPath stringByAppendingPathComponent:@"methodman2.png"],
				@"name": @"Method Man"
			},
			@{
				@"path": [kDefaultImagesPath stringByAppendingPathComponent:@"mastakilla.png"],
				@"name": @"Masta Killa"
			},
			@{
				@"path": [kDefaultImagesPath stringByAppendingPathComponent:@"ins.png"],
				@"name": @"Inspectah Deck"
			},
			@{
				@"path": [kDefaultImagesPath stringByAppendingPathComponent:@"odb.png"],
				@"name": @"Ol' Dirty Bastard"
			},
			@{
				@"path": [kDefaultImagesPath stringByAppendingPathComponent:@"ghostface.png"],
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
	[self updateUserImageList];
	[super viewWillAppear:animated];
}
//- (void)didReceiveMemoryWarning {
//	DebugLog(@"emptying image cache");
//	[self.imageCache removeAllObjects];
//	[super didReceiveMemoryWarning];
//}
//- (void)viewWillDisappear:(BOOL)animated {
//	DebugLog(@"emptying image cache");
//	[self.imageCache removeAllObjects];
//	[super viewWillDisappear:animated];
//}
- (void)updateUserImageList {
	NSMutableArray *results = [NSMutableArray array];
	NSArray *keys = @[NSURLNameKey];
	
	NSURL *url = [NSURL fileURLWithPath:kUserImagesPath isDirectory:YES];
	DebugLog(@"Scanning for user files at: %@ ...", url);

	NSArray *imageURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url
													   includingPropertiesForKeys:keys
																		  options:NSDirectoryEnumerationSkipsHiddenFiles
																			error:nil];
	DebugLog(@"Found these files: %@", imageURLs);
	
	// sort results by name
	[(NSMutableArray *)imageURLs sortUsingComparator:^(NSURL *a, NSURL *b) {
		NSDate *name1 = [[a resourceValuesForKeys:keys error:nil] objectForKey:NSURLNameKey];
		NSDate *name2 = [[b resourceValuesForKeys:keys error:nil] objectForKey:NSURLNameKey];
		return [name2 compare:name1];
	}];
	
	// process results...
	for (NSURL *imageURL in imageURLs) {
		NSString *path = [imageURL path];
		
		// check if the file is an image by trying to load it
		if ([UIImage imageWithContentsOfFile:[imageURL path]] == nil) {
			// file is not an image, ignore it
		} else {
			// file is good, add to results
			NSString *filename = [imageURL resourceValuesForKeys:keys error:nil][NSURLNameKey];
			[results addObject:@{ @"path":path, @"name":filename }];
		}
	}
	DebugLog(@"Found these images: %@", results);
	
	self.userImages = results;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Default images";
	} else if (section == 1) {
		return @"User images";
	} else {
		return nil;
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
	static NSString *CustomCellIdentifier = @"CustomCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:CustomCellIdentifier];
		cell.opaque = YES;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		// thumbnail
		UIImage *bgTile = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/Wu-Lock.bundle/tile.png"];
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 64, 64)];
		imageView.opaque = YES;
		imageView.contentMode = UIViewContentModeScaleAspectFit;
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
	
	// populate cell...
	
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
				//DebugLog(@"created thumbnail: %@", thumb);
				
				// add to cache
				[self.imageCache setObject:thumb forKey:path];
				//DebugLog(@"cached with key: %@", path);
				
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
			// yes!
			self.checkedIndexPath = indexPath;
		}
	}
	
	if ([indexPath isEqual:self.checkedIndexPath]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
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
		
		// get the image info
		NSDictionary *imageInfo;
		if (indexPath.section == 0) {
			imageInfo = self.defaultImages[indexPath.row];
		} else {
			imageInfo = self.userImages[indexPath.row];
		}
		
		// save selection to prefs
		selectedGlyph = imageInfo[@"path"];
		DebugLog(@"saving selected image: %@", selectedGlyph);
		CFPreferencesSetAppValue(kSelectedGlyphKey, (CFStringRef)selectedGlyph, kAppID);
		CFPreferencesAppSynchronize(kAppID);
		
		// notify tweak
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
											 CFSTR("com.sticktron.wu-lock.settingschanged"),
											 NULL, NULL, true);
		
		// TODO: should update thumbnail of parent link cell here
	}
}
@end

