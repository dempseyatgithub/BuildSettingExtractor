//
//  Constants+Categories.h
//  BuildSettingExtractor
//
//  Created by James Dempsey on 1/30/15.
//  Copyright (c) 2015 Tapas Software. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSUInteger, BuildSettingExtractorErrorCodes) {
    UnsupportedXcodeVersion = 100,
    DirectoryContainsBuildConfigFiles = 101,
    ProjectSettingsNamingConflict = 102,
    NoSettingsFoundInProjectFile = 103,
    BuildSettingInfoSourceNotFound = 104,
    BuildSettingInfoFilesNotFound = 105,
    BuildSettingInfoSubpathNotFound = 106,
};

extern NSErrorDomain const TPSBuildSettingExtractorErrorDomain;
extern NSString * TPSMultipleUnderlyingErrorsKey(void);

#pragma mark -

@interface  NSString (TPS_TypeIdentifierAdditions)
+ (NSString *)tps_projectBundleTypeIdentifier;
+ (NSString *)tps_buildConfigurationFileTypeIdentifier;
+ (NSString *)tps_preferredTypeIdentifierForFileExtension:(NSString *)string;
@end

@interface NSString (TPS_BuildSettingAdditions)
- (NSString *)tps_baseBuildSettingName; // Removes any conditional section of a build setting
- (BOOL)tps_baseBuildSettingNameIsEqualTo:(NSString *)buildSettingName; // returns YES if provided build setting name has the same base as the receiver
@end

#pragma mark -

@interface NSDictionary (TPS_BuildSettingAdditions)
// Assumes that a dictionary of build settings always has NSString values
// Returns NO if all the values in a dictionary are an empty string
// Raises an exception if used on a dictionary with any non-NSString value
- (BOOL)tps_containsBuildSettings;

// Returns a new dictionary containing all entries in the receiver except for
// entries with an empty string value.
- (NSDictionary *)tps_dictionaryByRemovingEmptyStringValues;
@end

#pragma mark -

@interface NSError (TPS_BuildSettingExtractorAdditions)

// Notify the user we are not using the exact name for the project settings provided in Preferences
+ (NSError *)errorForNameConflictWithName:(NSString *)conflictedName validatedName:(NSString *)validatedName;

// Notify the user we did not find any settings in the project.
+ (NSError *)errorForNoSettingsFoundInProject:(NSString *)projectName;

// Notify the user the project version is unsupported
+ (NSError *)errorForUnsupportedProjectURL:(NSURL *)projectWrapperURL fileVersion:(NSString *)compatibilityVersion;

// Notify the user no build setting info source could was found
+ (NSError *)errorForUnresolvedBuildSettingInfoSource;

// Notify the user the destination folder already contains build config files
+ (NSError *)errorForDestinationContainsBuildConfigFiles;

// Error that one or more expected build setting info files were not found
// User info includes NSMultipleUnderlyingErrorsKey to report underlying errors
+ (NSError *)errorForSettingInfoFilesNotFound:(NSArray *)subpathErrorStrings;

@end

#pragma mark -

@interface EmptyStringTransformer: NSValueTransformer {}
@end
