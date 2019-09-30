//
//  NSPasteboard+TPS_XcodeProjectReadingExtensions.m
//  BuildSettingExtractor
//
//  Created by James Dempsey on 1/30/15.
//  Copyright (c) 2015 Tapas Software. All rights reserved.
//

#import "Constants+Categories.h"

@implementation  NSString (TPS_TypeIdentifierAdditions)

+ (NSString *)tps_projectBundleTypeIdentifier {
    static NSString *projectBundleTypeIdentifier;
    if (!projectBundleTypeIdentifier) {
        projectBundleTypeIdentifier = [self tps_preferredTypeIdentifierForFileExtension:@"xcodeproj"];
//        NSLog(@"Xcode UTI: %@", projectBundleTypeIdentifier);
    }
    return projectBundleTypeIdentifier;
}

+ (NSString *)tps_buildConfigurationFileTypeIdentifier {
    static NSString *buildConfigurationFileTypeIdentifier;
    if (!buildConfigurationFileTypeIdentifier) {
        buildConfigurationFileTypeIdentifier = [self tps_preferredTypeIdentifierForFileExtension:@"xcconfig"];
//        NSLog(@"xcconfig UTI: %@", buildConfigurationFileTypeIdentifier);
    }
    return buildConfigurationFileTypeIdentifier;
}

+ (NSString *)tps_preferredTypeIdentifierForFileExtension:(NSString *)string {
    NSString *identifier = CFBridgingRelease(UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)string, NULL));
    return identifier;
}

@end

#pragma mark -

@implementation NSString (TPS_BuildSettingAdditions)

- (NSString *)tps_baseBuildSettingName {
    NSString *baseBuildSettingName = [self copy];
    NSRange range = [baseBuildSettingName rangeOfString:@"["]; // delimeter for a conditional build setting
    if (range.location != NSNotFound) {
        baseBuildSettingName = [baseBuildSettingName substringToIndex:range.location];
    }
    return baseBuildSettingName;
}

@end

#pragma mark -

@implementation NSDictionary (TPS_BuildSettingAdditions)

    - (BOOL)containsBuildSettings {
        BOOL foundNonEmptyString = NO;
        for (id value in self.allValues) {
            if ([value isKindOfClass:[NSString class]]) {
                if (![(NSString *)value isEqualToString:@""]) {
                    foundNonEmptyString = YES;
                    break;
                }
            } else {
                [NSException raise:(NSInternalInconsistencyException) format:@"-containsBuildSetting is expected to be called on a dictionary with NSString values."];
            }
        }
        return foundNonEmptyString;
    }

@end

#pragma mark -

@implementation NSError (TPS_BuildSettingExtractorAdditions)

// Notify the user we are not using the exact name for the project settings provided in Preferences
+ (NSError *)errorForNameConflictWithName:(NSString *)conflictedName validatedName:(NSString *)validatedName {
    NSString *errorDescription = [NSString stringWithFormat:@"Project settings filename conflict."];
    NSString *errorRecoverySuggestion = [NSString stringWithFormat:@"The target \'%@\' has the same name as the project name set in Preferences.\n\nThe generated project settings files will use the name \'%@\' to avoid a conflict.", conflictedName, validatedName];
    NSDictionary *errorUserInfo = @{NSLocalizedDescriptionKey:errorDescription, NSLocalizedRecoverySuggestionErrorKey: errorRecoverySuggestion};
    
    NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:ProjectSettingsNamingConflict userInfo:errorUserInfo];
    
    return error;
}

// Notify the user we did not find any settings in the project.
+ (NSError *)errorForNoSettingsFoundInProject:(NSString *)projectName {
    NSString *errorDescription = [NSString stringWithFormat:@"No settings found."];
    NSString *errorRecoverySuggestion = [NSString stringWithFormat:@"No settings were found in the project \'%@\'.\n\nThe project may already be using .xcconfig files for its build settings.\n\nNo xcconfig files will be written. ", projectName];
    NSDictionary *errorUserInfo = @{NSLocalizedDescriptionKey:errorDescription, NSLocalizedRecoverySuggestionErrorKey: errorRecoverySuggestion};
    
    NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:NoSettingsFoundInProjectFile userInfo:errorUserInfo];
    
    return error;
}

@end


