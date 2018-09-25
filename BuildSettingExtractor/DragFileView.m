//
//  DragFileView.m
//  BuildSettingExtractor
//
//  Created by James Dempsey on 1/30/15.
//  Copyright (c) 2015 Tapas Software. All rights reserved.
//

#import "DragFileView.h"
#import "Constants+Categories.h"


@interface DragFileView ()
@property NSURL *fileURL;
@property (weak) IBOutlet NSTextField *labelView;
@end

@implementation DragFileView

- (void)commonInit {
    self.boxType = NSBoxCustom;
    self.cornerRadius = 20.0;
    self.borderWidth = 0.0;
    [self setHighlight:NO];
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
        if (@available(macOS 10.14, *)) {
            self.fillColor = [[NSColor colorNamed: @"dragViewBackgroundColor"] colorWithSystemEffect:NSColorSystemEffectPressed];
        } else {
            self.fillColor = [NSColor colorWithCalibratedRed:0.56 green:0.7 blue:0.81 alpha:1.0];
        }
    } else {
        if (@available(macOS 10.13, *)) {
            self.fillColor = [NSColor colorNamed: @"dragViewBackgroundColor"];
        } else {
            self.fillColor = [NSColor colorWithCalibratedRed:0.7 green:0.85 blue:1.0 alpha:1.0];
        }
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
