//
//  BuildSettingExtractor.h
//  BuildSettingExtractor
//
//  Created by James Dempsey on 1/30/15.
//  Copyright (c) 2015 Tapas Software. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BuildSettingExtractor : NSObject

/* The generated file names take the form '<ProjectOrTargetName><separator><BuildConfigurationName>.xcconfig'
 
 For the <ProjectOrTargetName> piece:
 Target build setting files use the name of the target.
 Project build setting files use the value of -projectConfigName.
 
 For the <BuildConfigurationName> piece:
 Files containing the settings unique to a Build Configuration use the name of the build configuration.
 Files containing settings common to all build configurations for a target use the value of -sharedConfigName.
 
 For the <separator> piece:
 The separator used is the value of -nameSeparator.
 */

// The default values for naming of generated files. Potentially useful to register as defaults in an app.
+ (NSString *)defaultSharedConfigName; // "Shared" is the default.
+ (NSString *)defaultProjectConfigName; // "Project" is the default.
+ (NSString *)defaultNameSeparator; // "-" (hyphen) is the default.


// The name that will be used to name common / shared config files.
@property (copy) NSString *sharedConfigName;

// The name that will be used to name the project configuration.
@property (copy) NSString *projectConfigName;

// The string that will separate filename components.
@property (copy) NSString *nameSeparator;


// Should each build setting be commented with title and description, if available. 
@property (assign) BOOL includeBuildSettingInfoComments;

// Returns whether extraction of build settings was successful
- (BOOL)extractBuildSettingsFromProject:(NSURL *)projectWrapperURL toDestinationFolder:(NSURL *)folderURL;

@end

NS_ASSUME_NONNULL_END
