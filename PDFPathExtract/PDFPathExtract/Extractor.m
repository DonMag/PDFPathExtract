//
//  Extractor.m
//  PDFPathExtract
//
//  Created by Don Mag on 11/14/24.
//

#import "Extractor.h"

@implementation Extractor

void ExtractPathsFromContent(CGPDFScannerRef scanner, void *info);

void moveToCallback(CGPDFScannerRef scanner, void *info);
void lineToCallback(CGPDFScannerRef scanner, void *info);
void curveToCallback(CGPDFScannerRef scanner, void *info);
void closePathCallback(CGPDFScannerRef scanner, void *info);

CGMutablePathRef currentPath = NULL;

+ (NSArray<id> *)extractVectorPathsFromPDF:(NSURL *)pdfURL {
	PDFDocument *pdfDocument = [[PDFDocument alloc] initWithURL:pdfURL];
	if (!pdfDocument) {
		NSLog(@"Unable to load PDF document.");
		return nil;
	}
	
	NSMutableArray<id> *vectorPaths = [NSMutableArray array];
	
	// Iterate through all pages in the PDF document
	for (NSInteger pageIndex = 0; pageIndex < pdfDocument.pageCount; pageIndex++) {
		PDFPage *pdfPage = [pdfDocument pageAtIndex:pageIndex];
		if (!pdfPage) continue;
		
		CGPDFPageRef cgPage = pdfPage.pageRef;
		if (!cgPage) continue;
		
		// Set up the scanner to process PDF content streams
		CGPDFContentStreamRef contentStream = CGPDFContentStreamCreateWithPage(cgPage);
		CGPDFOperatorTableRef operatorTable = CGPDFOperatorTableCreate();
		
		// Register custom callbacks for common operators for path extraction
		CGPDFOperatorTableSetCallback(operatorTable, "m", &moveToCallback);  // move to
		CGPDFOperatorTableSetCallback(operatorTable, "l", &lineToCallback);  // line to
		CGPDFOperatorTableSetCallback(operatorTable, "c", &curveToCallback); // curve to
		CGPDFOperatorTableSetCallback(operatorTable, "h", &closePathCallback); // close path
		
		CGPDFScannerRef scanner = CGPDFScannerCreate(contentStream, operatorTable, (__bridge void *)(vectorPaths));
		
		// Initialize a new path for the page
		currentPath = CGPathCreateMutable();
		
		// Scan the PDF content
		CGPDFScannerScan(scanner);
		
		// After scanning, add the current path to the paths array
		if (currentPath) {
			[vectorPaths addObject:(__bridge_transfer id)currentPath];
			currentPath = NULL;
		}
		
		// Clean up
		CGPDFScannerRelease(scanner);
		CGPDFContentStreamRelease(contentStream);
		CGPDFOperatorTableRelease(operatorTable);
	}
	
	return [vectorPaths copy];
}

// Callback for "move to" operator
void moveToCallback(CGPDFScannerRef scanner, void *info) {
	CGPDFReal x, y;
	if (CGPDFScannerPopNumber(scanner, &y) && CGPDFScannerPopNumber(scanner, &x)) {
		CGPathMoveToPoint(currentPath, NULL, x, y);
	}
}

// Callback for "line to" operator
void lineToCallback(CGPDFScannerRef scanner, void *info) {
	CGPDFReal x, y;
	if (CGPDFScannerPopNumber(scanner, &y) && CGPDFScannerPopNumber(scanner, &x)) {
		CGPathAddLineToPoint(currentPath, NULL, x, y);
	}
}

// Callback for "curve to" operator
void curveToCallback(CGPDFScannerRef scanner, void *info) {
	CGPDFReal x1, y1, x2, y2, x3, y3;
	if (CGPDFScannerPopNumber(scanner, &y3) && CGPDFScannerPopNumber(scanner, &x3) &&
		CGPDFScannerPopNumber(scanner, &y2) && CGPDFScannerPopNumber(scanner, &x2) &&
		CGPDFScannerPopNumber(scanner, &y1) && CGPDFScannerPopNumber(scanner, &x1)) {
		CGPathAddCurveToPoint(currentPath, NULL, x1, y1, x2, y2, x3, y3);
	}
}

// Callback for "close path" operator
void closePathCallback(CGPDFScannerRef scanner, void *info) {
	CGPathCloseSubpath(currentPath);
}

@end
