//
//  AppConstants+Categories.m
//  BuildSettingExtractor
//
//  Created by James Dempsey on 9/30/19.
//  Copyright © 2019 Tapas Software. All rights reserved.
//

#import "AppConstants+Categories.h"
#import "Constants+Categories.h"
#import "BuildSettingExtractor.h"

#pragma mark User Default Keys

NSString *const TPSOpenDirectoryInFinder = @"TPSOpenDirectoryInFinder";
NSString *const TPSIncludeBuildSettingInfoComments = @"TPSIncludeBuildSettingInfoComments";
NSString *const TPSOutputFileNameProject = @"TPSOutputFileNameProject";
NSString *const TPSOutputFileNameShared = @"TPSOutputFileNameShared";
NSString *const TPSOutputFileNameSeparator = @"TPSOutputFileNameSeparator";
NSString *const TPSLinesBetweenBuildSettings = @"TPSLinesBetweenBuildSettings";
NSString *const TPSLinesBetweenBuildSettingsWithInfo = @"TPSLinesBetweenBuildSettingsWithInfo";
NSString *const TPSTargetFoldersEnabled = @"TPSTargetFoldersEnabled";
NSString *const TPSProjectFolderEnabled = @"TPSProjectFolderEnabled";
NSString *const TPSDestinationFolderName = @"TPSDestinationFolderName";
NSString *const TPSAutosaveInProjectFolder = @"TPSAutosaveInProjectFolder";
NSString *const TPSAlignBuildSettingValues = @"TPSAlignBuildSettingValues";

@implementation NSUserDefaults (TPS_DefaultsRegistration)
- (void)tps_registerApplicationDefaults {
    NSDictionary *defaults = @{
        TPSOpenDirectoryInFinder : @(YES),
        TPSIncludeBuildSettingInfoComments : @(YES),
        TPSOutputFileNameShared : BuildSettingExtractor.defaultSharedConfigName,
        TPSOutputFileNameProject : BuildSettingExtractor.defaultProjectConfigName,
        TPSOutputFileNameSeparator : BuildSettingExtractor.defaultNameSeparator,
        TPSLinesBetweenBuildSettings : @0,
        TPSLinesBetweenBuildSettingsWithInfo : @3,
        TPSTargetFoldersEnabled : @(NO),
        TPSProjectFolderEnabled : @(NO),
        TPSDestinationFolderName : BuildSettingExtractor.defaultDestinationFolderName,
        TPSAutosaveInProjectFolder: @(NO),
        TPSAlignBuildSettingValues: @(NO)
    };
    [self registerDefaults:defaults];
}
@end

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



