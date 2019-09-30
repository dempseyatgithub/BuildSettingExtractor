//
//  AppConstants+Categories.m
//  BuildSettingExtractor
//
//  Created by James Dempsey on 9/30/19.
//  Copyright © 2019 Tapas Software. All rights reserved.
//

#import "AppConstants+Categories.h"
#import "Constants+Categories.h"

#pragma mark User Default Keys

NSString *const TPSOpenDirectoryInFinder = @"TPSOpenDirectoryInFinder";
NSString *const TPSIncludeBuildSettingInfoComments = @"TPSIncludeBuildSettingInfoComments";
NSString *const TPSOutputFileNameProject = @"TPSOutputFileNameProject";
NSString *const TPSOutputFileNameShared = @"TPSOutputFileNameShared";
NSString *const TPSOutputFileNameSeparator = @"TPSOutputFileNameSeparator";


#pragma mark -

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



