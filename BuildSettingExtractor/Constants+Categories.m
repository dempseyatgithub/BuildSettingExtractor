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

