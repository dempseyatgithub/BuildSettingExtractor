//
//  DragFileView.m
//  BuildSettingExtractor
//
//  Created by James Dempsey on 1/30/15.
//  Copyright (c) 2015 Tapas Software. All rights reserved.
//

#import "DragFileView.h"
@import ExtractorKit;


@interface DragFileView ()
@property NSURL *fileURL;
@property (weak) IBOutlet NSTextField *labelView;
@end

@implementation DragFileView

- (void)commonInit {
    self.wantsLayer = YES;
    [self setHighlight:NO];
    self.layer.cornerRadius = 20.0;
    [self registerForDraggedTypes:@[(NSString *)kUTTypeFileURL]];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) { [self commonInit]; } return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) { [self commonInit]; } return self;
}

- (void)setHighlight:(BOOL)flag {
    if (flag) {
        self.layer.backgroundColor = [[NSColor colorWithCalibratedRed:0.56 green:0.7 blue:0.81 alpha:1.0] CGColor];
    } else {
        self.layer.backgroundColor = [[NSColor colorWithCalibratedRed:0.7 green:0.85 blue:1.0 alpha:1.0] CGColor];
    }
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {

    BOOL canRead = [[sender draggingPasteboard] tps_canReadXcodeProjectFileURL];

    if (canRead) {
        [self setHighlight:YES];
        return NSDragOperationGeneric;
    } else {
        return NSDragOperationNone;
    }
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
    [self setHighlight:NO];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    return [[sender draggingPasteboard] tps_canReadXcodeProjectFileURL];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    self.fileURL = [[sender draggingPasteboard] tps_readXcodeProjectFileURL];
    return self.fileURL != nil;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
    [self setHighlight:NO];
    [NSApp sendAction:self.action to:self.target from:self];
}

@end
