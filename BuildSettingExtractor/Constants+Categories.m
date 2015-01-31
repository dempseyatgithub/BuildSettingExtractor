//
//  NSPasteboard+TPS_XcodeProjectReadingExtensions.m
//  BuildSettingExtractor
//
//  Created by James Dempsey on 1/30/15.
//  Copyright (c) 2015 Tapas Software. All rights reserved.
//

#import "Constants+Categories.h"

@implementation NSPasteboard (TPS_XcodeProjectURLAdditions)

- (NSURL *)tps_readXcodeProjectFileURL {
    NSArray *readObjects = [self readObjectsForClasses:@[[NSURL class]] options:[self tps_xcodeProjectReadingOptions]];
    return readObjects.firstObject;
}

- (BOOL)tps_canReadXcodeProjectFileURL {
    return [self canReadObjectForClasses:@[[NSURL class]] options:[self tps_xcodeProjectReadingOptions]];
}

- (NSDictionary *)tps_xcodeProjectReadingOptions {
    return @{NSPasteboardURLReadingFileURLsOnlyKey: @(YES), NSPasteboardURLReadingContentsConformToTypesKey: @[[NSString tps_projectBundleTypeIdentifier]]};
}

@end


#pragma mark -


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
