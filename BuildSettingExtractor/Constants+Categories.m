//
//  NSPasteboard+TPS_XcodeProjectReadingExtensions.m
//  BuildSettingExtractor
//
//  Created by James Dempsey on 1/30/15.
//  Copyright (c) 2015 Tapas Software. All rights reserved.
//

#import "Constants+Categories.h"

NSErrorDomain const TPSBuildSettingExtractorErrorDomain = @"TPSBuildSettingExtractorErrorDomain";

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

- (BOOL)tps_containsBuildSettings {
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

- (NSDictionary *)tps_dictionaryByRemovingEmptyStringValues {
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        if (![value isEqualTo:@""]) {
            [temp setValue:value forKey:key];
        }
    }];
    return temp;
}

@end

#pragma mark -

@implementation NSError (TPS_BuildSettingExtractorAdditions)

// Notify the user we are not using the exact name for the project settings provided in Preferences
+ (NSError *)errorForNameConflictWithName:(NSString *)conflictedName validatedName:(NSString *)validatedName {
    NSString *errorDescription = [NSString stringWithFormat:@"Project settings filename conflict."];
    NSString *errorRecoverySuggestion = [NSString stringWithFormat:@"The target \'%@\' has the same name as the project name set in Preferences.\n\nThe generated project settings files will use the name \'%@\' to avoid a conflict.", conflictedName, validatedName];
    NSDictionary *errorUserInfo = @{NSLocalizedDescriptionKey:errorDescription, NSLocalizedRecoverySuggestionErrorKey: errorRecoverySuggestion};
    
    NSError *error = [NSError errorWithDomain:TPSBuildSettingExtractorErrorDomain code:ProjectSettingsNamingConflict userInfo:errorUserInfo];
    
    return error;
}

// Notify the user we did not find any settings in the project.
+ (NSError *)errorForNoSettingsFoundInProject:(NSString *)projectName {
    NSString *errorDescription = [NSString stringWithFormat:@"No settings found."];
    NSString *errorRecoverySuggestion = [NSString stringWithFormat:@"No settings were found in the project \'%@\'.\n\nThe project may already be using .xcconfig files for its build settings.\n\nNo xcconfig files will be written. ", projectName];
    NSDictionary *errorUserInfo = @{NSLocalizedDescriptionKey:errorDescription, NSLocalizedRecoverySuggestionErrorKey: errorRecoverySuggestion};
    
    NSError *error = [NSError errorWithDomain:TPSBuildSettingExtractorErrorDomain code:NoSettingsFoundInProjectFile userInfo:errorUserInfo];
    
    return error;
}


+ (NSError *)errorForUnsupportedProjectURL:(NSURL *)projectWrapperURL fileVersion:(NSString *)compatibilityVersion {
NSDictionary *userInfo = @{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Unable to extract build settings from project ‘%@’.", [[projectWrapperURL lastPathComponent] stringByDeletingPathExtension]], NSLocalizedRecoverySuggestionErrorKey: [NSString stringWithFormat:@"Project file format version ‘%@’ is not supported.", compatibilityVersion]};

    NSError *error = [NSError errorWithDomain:TPSBuildSettingExtractorErrorDomain code:UnsupportedXcodeVersion userInfo:userInfo];

    return error;
}

+ (NSError *)errorForUnresolvedBuildSettingInfoSource {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"No source of build setting info was found.", NSLocalizedRecoverySuggestionErrorKey:@"Xcode or Xcode-beta must be installed in the Applications folder to generate descriptive build setting comments.\n\nConfiguration files will be generated without comments."};

    NSError *error = [NSError errorWithDomain:TPSBuildSettingExtractorErrorDomain code:BuildSettingInfoSourceNotFound userInfo:userInfo];

    return error;
}

+ (NSError *)errorForDestinationContainsBuildConfigFiles {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"Build config files already exist in this folder. Do you want to replace them?", NSLocalizedRecoveryOptionsErrorKey:@[@"Cancel", @"Replace"], NSLocalizedRecoverySuggestionErrorKey:@"Build configuration files already exist in this folder. Replacing will overwrite any files with the same file names."};

    NSError *error = [NSError errorWithDomain:TPSBuildSettingExtractorErrorDomain code:DirectoryContainsBuildConfigFiles userInfo:userInfo];

    return error;
}

@end

#pragma mark -

@implementation EmptyStringTransformer
+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return YES; }

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[NSString class]] && [value isEqualToString:@""]) {
        return nil;
    } else if (value == nil) {
        return @"";
    } else {
        return value;
    }
}

- (id)reversedTransformedValue:(id)value {
    if (value == nil) { return @""; }
    else { return value; }
}
@end

