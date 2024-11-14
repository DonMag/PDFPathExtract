//
//  ViewController.m
//  PDFPathExtract
//
//  Created by Don Mag on 11/14/24.
//

#import "ViewController.h"
#import "CheckerBoardView.h"
#import "Extractor.h"
#import <QuartzCore/QuartzCore.h>	// for CAShapeLayer

@interface ViewController ()
{
	NSPopUpButton *comboButton;
	NSImageView *imgView;
	NSView *pathOutlineView;
	NSView *pathFilledView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSArray<NSString *> *pdfFiles = [self filesInBundleWithExtension:@"pdf"];
	if (pdfFiles.count == 0) {
		return;
	}
	
	comboButton = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 100, 30) pullsDown:NO];
	[comboButton addItemsWithTitles:pdfFiles];
	[comboButton setTarget:self];
	[comboButton setAction:@selector(comboButtonSelectionChanged:)];
	
	NSTextField *promptLabel = [NSTextField new];
	
	promptLabel.stringValue = @"Select a PDF from the Bundle to Validate";
	promptLabel.editable = NO;
	promptLabel.bezeled = NO;
	promptLabel.drawsBackground = NO;
	promptLabel.selectable = NO;
	promptLabel.font = [NSFont systemFontOfSize:15.0];
	
	
	imgView = [NSImageView new];
	imgView.wantsLayer = YES;
	imgView.imageScaling = NSImageScaleProportionallyUpOrDown;
	imgView.contentTintColor = NSColor.redColor;
	
	CAShapeLayer *c;
	
	pathOutlineView = [NSView new];
	pathOutlineView.wantsLayer = YES;
	c = [CAShapeLayer new];
	c.fillColor = NULL;
	c.strokeColor = NSColor.redColor.CGColor;
	c.lineWidth = 1.0;
	[pathOutlineView.layer addSublayer:c];
	
	pathFilledView = [NSView new];
	pathFilledView.wantsLayer = YES;
	c = [CAShapeLayer new];
	c.fillColor = NSColor.systemYellowColor.CGColor;
	c.strokeColor = NSColor.redColor.CGColor;
	c.lineWidth = 1.0;
	[pathFilledView.layer addSublayer:c];
	
	NSStackView *bgstack = [NSStackView new];
	bgstack.spacing = 20.0;
	bgstack.distribution = NSStackViewDistributionFillEqually;
	
	NSStackView *stack = [NSStackView new];
	stack.spacing = 20.0;
	stack.distribution = NSStackViewDistributionFillEqually;
	
	CGFloat sz = 240.0;
	
	for (NSView *v in @[imgView, pathOutlineView, pathFilledView]) {
		v.translatesAutoresizingMaskIntoConstraints = NO;
		[stack addArrangedSubview:v];
		[v.heightAnchor constraintEqualToConstant:sz].active = YES;
		[v.widthAnchor constraintEqualToConstant:sz].active = YES;
		
		CheckerBoardView *cbv = [CheckerBoardView new];
		cbv.translatesAutoresizingMaskIntoConstraints = NO;
		[bgstack addArrangedSubview:cbv];
		[cbv.heightAnchor constraintEqualToConstant:sz].active = YES;
		[cbv.widthAnchor constraintEqualToConstant:sz].active = YES;
	}
	
	for (NSView *v in @[promptLabel, comboButton, bgstack, stack]) {
		v.translatesAutoresizingMaskIntoConstraints = NO;
		[self.view addSubview:v];
	}
	
	NSView *g = self.view;
	[NSLayoutConstraint activateConstraints:@[
		[promptLabel.centerXAnchor constraintEqualToAnchor:g.centerXAnchor],
		[promptLabel.topAnchor constraintEqualToAnchor:g.topAnchor constant:16.0],
		[comboButton.widthAnchor constraintEqualToConstant:240.0],
		[comboButton.centerXAnchor constraintEqualToAnchor:g.centerXAnchor],
		[comboButton.topAnchor constraintEqualToAnchor:promptLabel.bottomAnchor constant:8.0],
		
		[bgstack.centerXAnchor constraintEqualToAnchor:g.centerXAnchor],
		[bgstack.centerYAnchor constraintEqualToAnchor:g.centerYAnchor],
		[stack.centerXAnchor constraintEqualToAnchor:g.centerXAnchor],
		[stack.centerYAnchor constraintEqualToAnchor:g.centerYAnchor],
	]];
}

- (NSArray<NSString *> *)filesInBundleWithExtension:(NSString *)extension {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *bundlePath = [[NSBundle mainBundle] resourcePath];
	NSError *error = nil;
	
	// Get all files in the bundle's resource directory
	NSArray<NSString *> *allFiles = [fileManager contentsOfDirectoryAtPath:bundlePath error:&error];
	
	if (error) {
		NSLog(@"Error reading bundle contents: %@", error.localizedDescription);
		return @[];
	}
	
	// Filter files that have the specified extension
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self ENDSWITH[c] %@", extension];
	NSArray<NSString *> *matchingFiles = [allFiles filteredArrayUsingPredicate:predicate];
	
	return matchingFiles;
}

- (void)viewDidAppear {
	[super viewDidAppear];
	[self comboButtonSelectionChanged:comboButton];
}

- (void)comboButtonSelectionChanged:(NSPopUpButton *)sender {
	NSString *selectedOption = sender.titleOfSelectedItem;
	NSLog(@"Selected option: %@", selectedOption);
	
	NSString *imagePath = [[NSBundle mainBundle] pathForResource:selectedOption ofType:NULL];
	NSURL *pdfUrl = [NSURL fileURLWithPath:imagePath isDirectory:NO];
	
	NSImage *img = [[NSImage alloc] initWithContentsOfURL:pdfUrl];
	img.template = YES;
	imgView.image = img;
	
	NSArray<id> *vectorPaths = [Extractor extractVectorPathsFromPDF:pdfUrl];
	CGPathRef pth = (CGPathRef)CFBridgingRetain([vectorPaths firstObject]);
	
	// calculate target rect
	//	center and maintain aspect ratio
	CGRect pathRect = CGPathGetBoundingBox(pth);
	CGRect boundsRect = pathOutlineView.bounds;
	
	CGRect targRect = [self scaleRect:pathRect toFit:boundsRect];
	
	// transform path to fit
	CGMutablePathRef cpth2 = [self pathInTargetRect:targRect withPath:pth];
	if (!cpth2) {
		return;
	}
	
	CAShapeLayer *c;
	
	c = (CAShapeLayer *)pathOutlineView.layer.sublayers.firstObject;
	c.path = cpth2;
	
	c = (CAShapeLayer *)pathFilledView.layer.sublayers.firstObject;
	c.path = cpth2;
	
	CGPathRelease(cpth2);
	CGPathRelease(pth);
}

- (CGRect)scaleRect:(CGRect)sourceRect toFit:(CGRect)targetRect {
	CGFloat widthScale = targetRect.size.width / sourceRect.size.width;
	CGFloat heightScale = targetRect.size.height / sourceRect.size.height;
	CGFloat scaleFactor = MIN(widthScale, heightScale);
	CGFloat scaledWidth = sourceRect.size.width * scaleFactor;
	CGFloat scaledHeight = sourceRect.size.height * scaleFactor;
	CGFloat originX = targetRect.origin.x + (targetRect.size.width - scaledWidth) / 2.0;
	CGFloat originY = targetRect.origin.y + (targetRect.size.height - scaledHeight) / 2.0;
	return CGRectMake(originX, originY, scaledWidth, scaledHeight);;
}

- (CGMutablePathRef)pathInTargetRect:(CGRect)targetRect withPath:(CGMutablePathRef)path {
	if (!path) return NULL;
	
	// Get the current bounding rect of the path
	CGRect boundingBox = CGPathGetBoundingBox(path);
	
	// Translate the path to origin
	CGAffineTransform translateToOrigin = CGAffineTransformMakeTranslation(-boundingBox.origin.x, -boundingBox.origin.y);
	CGMutablePathRef translatedPath = CGPathCreateMutableCopyByTransformingPath(path, &translateToOrigin);
	
	if (!translatedPath) return NULL;
	
	// Scale the path to fit the target rectangle
	CGAffineTransform scaleTransform = CGAffineTransformMakeScale(targetRect.size.width / boundingBox.size.width,
																  targetRect.size.height / boundingBox.size.height);
	CGMutablePathRef scaledPath = CGPathCreateMutableCopyByTransformingPath(translatedPath, &scaleTransform);
	CGPathRelease(translatedPath); // Release the translated path
	
	if (!scaledPath) return NULL;
	
	// Translate the path to the target rectangle's origin
	CGAffineTransform translateToTarget = CGAffineTransformMakeTranslation(targetRect.origin.x, targetRect.origin.y);
	CGMutablePathRef finalPath = CGPathCreateMutableCopyByTransformingPath(scaledPath, &translateToTarget);
	CGPathRelease(scaledPath); // Release the scaled path
	
	return finalPath;
}

@end

/*
@interface ViewController ()
{
	NSView *pdfPathView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	// checker board pattern so we can see transparency around the rendered path
	CheckerBoardView *cv = [CheckerBoardView new];
	cv.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:cv];
	
	[NSLayoutConstraint activateConstraints:@[
		[cv.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0.0],
		[cv.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0.0],
		[cv.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0.0],
		[cv.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0.0],
	]];

	NSString *pdfName;
	
	pdfName = @"AW109";
	pdfName = @"AW109_fixed";
	pdfName = @"AC130";
	
	NSString *pdfPath = [[NSBundle mainBundle] pathForResource:pdfName ofType:@"pdf"];
	NSURL *pdfUrl = [NSURL fileURLWithPath:pdfPath isDirectory:NO];
	
	// get the paths from the PDF
	//	the PDF has only one page, so we're expecting only one path
	NSArray<id> *vectorPaths = [Extractor extractVectorPathsFromPDF:pdfUrl];
	CGPathRef pth = (CGPathRef)CFBridgingRetain([vectorPaths firstObject]);
	
	// translate path to 0,0
	CGRect boundingBox = CGPathGetBoundingBox(pth);
	CGAffineTransform translateToOrigin = CGAffineTransformMakeTranslation(-boundingBox.origin.x, -boundingBox.origin.y);
	CGMutablePathRef translatedPath = CGPathCreateMutableCopyByTransformingPath(pth, &translateToOrigin);
	
	// get the new path bounding box
	CGRect pathRect = CGPathGetBoundingBox(translatedPath);
	
	pdfPathView = [NSView new];
	pdfPathView.wantsLayer = YES;
	
	// let's give the path view a border so we can see the framing
	//	click anywhere in window to toggle the border on/off
	pdfPathView.layer.borderColor = NSColor.blackColor.CGColor;
	pdfPathView.layer.borderWidth = 1.0;

	// create shape layer
	CAShapeLayer *c = [CAShapeLayer new];
	c.fillColor = NSColor.systemYellowColor.CGColor;
	c.strokeColor = NSColor.redColor.CGColor;
	c.lineWidth = 1.0;

	// set the path
	c.path = translatedPath;
	
	// add the layer to the path view
	[pdfPathView.layer addSublayer:c];

	pdfPathView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:pdfPathView];
	
	// set the size of the path view to the size of the path's bounding box
	//	and center it
	[NSLayoutConstraint activateConstraints:@[
		[pdfPathView.widthAnchor constraintEqualToConstant:pathRect.size.width],
		[pdfPathView.heightAnchor constraintEqualToConstant:pathRect.size.height],
		[pdfPathView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
		[pdfPathView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
	]];

	// clean up
	CGPathRelease(translatedPath);
	CGPathRelease(pth);
}

- (void)mouseUp:(NSEvent *)event {
	pdfPathView.layer.borderWidth = pdfPathView.layer.borderWidth == 1.0 ? 0.0 : 1.0;
}

@end
*/
