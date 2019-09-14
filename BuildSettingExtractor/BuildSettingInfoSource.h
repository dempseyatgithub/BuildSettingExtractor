//
//  BuildSettingInfoSource.h
//  BuildSettingExtractor
//
//  Created by James Dempsey on 2/3/15.
//  Copyright (c) 2015 Tapas Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BuildSettingInfoSource : NSObject

- (NSString *)commentForBuildSettingWithName:(NSString *)buildSettingName;

- (BOOL)loadBuildSettingInfo; // Primarily for testing

@end
