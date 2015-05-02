//
//  BuildSettingExtractor.h
//  BuildSettingExtractor
//
//  Created by James Dempsey on 1/30/15.
//  Copyright (c) 2015 Tapas Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BuildSettingExtractor : NSObject

// The name that will be used to name common / shared config files.
@property (copy) NSString *sharedConfigName;
// "Shared" is the default.
+ (NSString *)sharedConfigNameDefault;

// The name that will be used to name the project configuration.
@property (copy) NSString *projectConfigName;
// "Project" is the default.
+ (NSString *)projectConfigNameDefault;

// The string that will separate filename components.
@property (copy) NSString *nameSeparator;
// "-" hyphen-case is the default.
+ (NSString *)nameSeparatorDefault;

// Should each build setting be commented with title and description, if available. 
@property (assign) BOOL includeBuildSettingInfoComments;

- (void)extractBuildSettingsFromProject:(NSURL *)projectWrapperURL toDestinationFolder:(NSURL *)folderURL;

@end
