//
//  BuildSettingExtractor.h
//  BuildSettingExtractor
//
//  Created by James Dempsey on 1/30/15.
//  Copyright (c) 2015 Tapas Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BuildSettingExtractor : NSObject

// The name that will be used to name common / shared config files. "Shared" is the default.
@property (copy) NSString *sharedConfigName;

// The name that will be used to name the project configuration. Default is "Project".
@property (copy) NSString *projectConfigName;

// Should each build setting be commented with title and description, if available. 
@property (assign) BOOL includeBuildSettingInfoComments;

- (void)extractBuildSettingsFromProject:(NSURL *)projectWrapperURL toDestinationFolder:(NSURL *)folderURL;

@end
