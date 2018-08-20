//
//  Constants+Categories.h
//  BuildSettingExtractor
//
//  Created by James Dempsey on 1/30/15.
//  Copyright (c) 2015 Tapas Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, AppErrorCodes) {
    UnsupportedXcodeVersion = 100,
    DirectoryContainsBuildConfigFiles = 101,
    ProjectSettingsNamingConflict = 102,
    NoSettingsFoundInProjectFile = 103,
};

extern NSString *const TPSOpenDirectoryInFinder;
extern NSString *const TPSIncludeBuildSettingInfoComments;
extern NSString *const TPSOutputFileNameProject;
extern NSString *const TPSOutputFileNameShared;
extern NSString *const TPSOutputFileNameSeparator;


#pragma mark -

@interface NSPasteboard (TPS_XcodeProjectURLAdditions)
- (BOOL)tps_canReadXcodeProjectFileURL;
- (NSURL *)tps_readXcodeProjectFileURL;
@end

#pragma mark -

@interface  NSString (TPS_TypeIdentifierAdditions)
+ (NSString *)tps_projectBundleTypeIdentifier;
+ (NSString *)tps_buildConfigurationFileTypeIdentifier;
+ (NSString *)tps_preferredTypeIdentifierForFileExtension:(NSString *)string;
@end

@interface NSString (TPS_BuildSettingAdditions)
- (NSString *)tps_baseBuildSettingName; // Removes any conditional section of a build setting
@end

#pragma mark -

@interface NSDictionary (TPS_BuildSettingAdditions)
// Assumes that a dictionary of build settings always has NSString values
// Returns NO if all the values in a dictionary are an empty string
// Raises an exception if used on a dictionary with any non-NSString value
- (BOOL)containsBuildSettings;
@end

