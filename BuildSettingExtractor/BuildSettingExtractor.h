//
//  BuildSettingExtractor.h
//  BuildSettingExtractor
//
//  Created by James Dempsey on 1/30/15.
//  Copyright (c) 2015 Tapas Software. All rights reserved.
//

@import Foundation;

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

// Number of lines between build settings. Default is 0.
@property NSInteger linesBetweenSettings;


// Should each build setting be commented with title and description, if available. Default is NO.
@property (assign) BOOL includeBuildSettingInfoComments;

// If set to YES the generated config files for each target will be put in a separate folder.
// Use with the projectFolderEnabled property for project-level config files. Default is NO.
@property BOOL targetFoldersEnabled;

// If set to YES project-level config files will be put in a separate folder.
// Only takes effect when targetFoldersEnabled is also set to YES. Default is NO.
@property BOOL projectFolderEnabled;

// If set to YES aligns the build settings in generated files. Default is NO.
@property BOOL alignBuildSettingValues;

// Validates destination folder, checking for existing build config files
// Returns an error suitable for presentation in an alert with options to cancel or replace existing files.
+ (BOOL)validateDestinationFolder:(NSURL *)destinationURL error:(NSError **)error;

// Extracts the build settings from the project.
// Returns an array of zero or more non-fatal validation errors or nil if a fatal error is encountered
- (nullable NSArray *)extractBuildSettingsFromProject:(NSURL *)projectWrapperURL error:(NSError **)error;

// After successful extraction, writes config files to the destination folder
// Returns whether the method was successful and an error if unsuccessful
//
// NOTE: This method will throw an exception if it is called before successful extraction of build settings
// by successful completion of -extractBuildSettingsFromProject:error:. Callers must call -extractBuildSettingsFromProject:error: first and check for a non-nil return value indicating success.
- (BOOL)writeConfigFilesToDestinationFolder:(NSURL *)destinationURL error:(NSError **)error;

// Generates an example build setting string using the provided settings dictionary and options. The settings dictionary keys are expected
// to be string. The values are expected to be strings or arrays of strings.
+ (NSString *)exampleBuildFormattingStringForSettings:(NSDictionary *)settings includeBuildSettingInfoComments:(BOOL)includeBuildSettingInfoComments alignBuildSettingValues:(BOOL)alignBuildSettingValues linesBetweenSettings:(NSInteger)linesBetweenSettings;

@end

NS_ASSUME_NONNULL_END
