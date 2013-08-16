//
//  ConsoleOutputTextView.m
//  Calabash GUI
//
//  Created by James Wegner on 7/26/13.
//  Copyright (c) 2013 James Wegner. All rights reserved.
//

#import "ConsoleOutputTextView.h"

@implementation ConsoleOutputTextView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        //[self setFont:[NSFont fontWithName:@"Menlo" size:14]];
        //[self setBackgroundColor:[NSColor blackColor]];
    }
    
    [self setTextColor:[NSColor whiteColor]];

    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
