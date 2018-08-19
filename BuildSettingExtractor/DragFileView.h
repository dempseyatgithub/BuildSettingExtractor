//
//  DragFileView.h
//  BuildSettingExtractor
//
//  Created by James Dempsey on 1/30/15.
//  Copyright (c) 2015 Tapas Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface DragFileView : NSBox

@property (readonly) NSURL *fileURL;

@property (weak) id target;
@property SEL action;

@end
