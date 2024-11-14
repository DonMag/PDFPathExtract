//
//  CheckBoardView.m
//  AirplanePath
//
//  Created by Don Mag on 11/10/24.
//

#import "CheckerBoardView.h"

@implementation CheckerBoardView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
	NSColor *color1 = [NSColor colorWithWhite:0.9 alpha:1.0];
	NSColor *color2 = [NSColor colorWithWhite:1.0 alpha:1.0];
	
	NSRect bounds = self.bounds;
	CGFloat squareSize = 12.0;
	
	// Calculate the number of squares in each direction
	NSInteger rows = ceil(bounds.size.height / squareSize);
	NSInteger columns = ceil(bounds.size.width / squareSize);
	
	// Loop through each square in the checkerboard
	for (NSInteger row = 0; row < rows; row++) {
		for (NSInteger col = 0; col < columns; col++) {
			// Determine color based on row and column indices
			BOOL isEvenSquare = (row + col) % 2 == 0;
			NSColor *color = isEvenSquare ? color1 : color2;
			
			[color setFill];
			
			// Calculate the square's rect
			NSRect squareRect = NSMakeRect(col * squareSize, row * squareSize, squareSize, squareSize);
			
			// Draw the square
			NSRectFill(squareRect);
		}
	}
}

@end
