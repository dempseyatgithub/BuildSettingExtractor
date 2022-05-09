//
//  BuildSettingCommentGenerator.h
//  BuildSettingExtractor
//
//  Created by James Dempsey on 2/3/15.
//  Copyright (c) 2015 Tapas Software. All rights reserved.
//

@import Foundation;

@class BuildSettingInfoSource;

@interface BuildSettingCommentGenerator : NSObject

- (instancetype)initWithBuildSettingInfoSource:(BuildSettingInfoSource *)infoSource;

- (NSString *)commentForBuildSettingWithName:(NSString *)buildSettingName;

- (BOOL)loadBuildSettingInfo:(NSError **)error; // In public interface for testing

@end
