//
//  BuildSettingExtractorTests.m
//  BuildSettingExtractorTests
//
//  Created by James Dempsey on 9/9/14.
//  Copyright (c) 2014 Tapas Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BuildSettingExtractor.h"
#import "BuildSettingInfoSource.h"
#import "Constants+Categories.h"

@interface NSObject (BuildSettingExtractorMethods)
- (NSDictionary *)buildSettingsByConfigurationForConfigurations:(NSArray *)buildConfigurations;
@end

@interface BuildSettingExtractorTests : XCTestCase
@end

@implementation BuildSettingExtractorTests

- (void)testThreeBuildConfigurations
{
    NSURL *testFileURL = [[NSBundle bundleForClass:[BuildSettingExtractorTests class]] URLForResource:@"ThreeBuildConfigs" withExtension:@"plist"];
    NSDictionary *testPlist = [NSDictionary dictionaryWithContentsOfURL:testFileURL];

    NSArray *buildConfigurations = testPlist[@"buildConfigurations"];
    NSDictionary *expectedBuildSettings = testPlist[@"expectedBuildSettings"];

    BuildSettingExtractor *extractor = [[BuildSettingExtractor alloc] init];

    NSDictionary *buildSettings = [extractor buildSettingsByConfigurationForConfigurations:buildConfigurations];

    NSDictionary *sharedBuildSettings = buildSettings[extractor.sharedConfigName];

    XCTAssert([sharedBuildSettings isEqualToDictionary:expectedBuildSettings], @"Build settings should match");
}

- (void)testDictionaryBuildSettingsCategory
{
    NSDictionary *dictionaryWithBuildSettings = @{ @"Shared": @"COPY_PHASE_STRIP = NO", @"Release": @"COPY_PHASE_STRIP = NO", @"Debug": @"COPY_PHASE_STRIP = NO" };
    XCTAssertTrue(dictionaryWithBuildSettings.containsBuildSettings);
    
    NSDictionary *dictionaryWithMinimalBuildSettings = @{ @"Shared": @"", @"Release": @"", @"Debug": @"COPY_PHASE_STRIP = NO" };
    XCTAssertTrue(dictionaryWithMinimalBuildSettings.containsBuildSettings);

    NSDictionary *dictionaryWithoutBuildSettings = @{ @"Shared": @"", @"Release": @"", @"Debug": @"" };
    XCTAssertFalse(dictionaryWithoutBuildSettings.containsBuildSettings);
    
    NSDictionary *badDictionary = @{@"Shared":@"", @"Release":@"", @"Debug":[NSDate date] };
    BOOL result = NO;
    XCTAssertThrows(result = badDictionary.containsBuildSettings);
}

- (void)testLoadingBuildSettingInfo
{
    BuildSettingInfoSource *source = [[BuildSettingInfoSource alloc] init];
    XCTAssertTrue([source loadBuildSettingInfo]);

}

- (void)testBadProjectURL
{
    NSError *error = nil;
    BuildSettingExtractor *extractor = [[BuildSettingExtractor alloc] init];
    
    NSURL *badURL = [NSURL fileURLWithPath:[@"~/Documents/BadProjectURL.xcodeproj" stringByExpandingTildeInPath]];

    NSArray *nonFatalErrors = [extractor extractBuildSettingsFromProject:badURL error:&error];
    
    XCTAssertNil(nonFatalErrors);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, 260);
    
}

// Reads the project.pbxproj file inside of BadProject.xcodeproj.test.
// A stripped down xcodeproj bundle with a malformed project.pbxproj plist.
- (void)testMalformedProjectFile
{
    NSError *error = nil;
    BuildSettingExtractor *extractor = [[BuildSettingExtractor alloc] init];

    NSURL *badProjectURL = [[NSBundle bundleForClass:[BuildSettingExtractorTests class]] URLForResource:@"BadProject.xcodeproj" withExtension:@"test"];

    NSArray *nonFatalErrors = [extractor extractBuildSettingsFromProject:badProjectURL error:&error];
    
    XCTAssertNil(nonFatalErrors);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, 3840); // "Junk after plist at line 545"

}

// Reads the project.pbxproj file inside of BadVersionNumber.xcodeproj.test.
// A stripped down xcodeproj bundle with its project version set to "Xcode 9999.9"
- (void)testIncompatibleProjectVersion
{
    NSError *error = nil;
    BuildSettingExtractor *extractor = [[BuildSettingExtractor alloc] init];

    NSURL *badProjectURL = [[NSBundle bundleForClass:[BuildSettingExtractorTests class]] URLForResource:@"BadVersionNumber.xcodeproj" withExtension:@"test"];

    NSArray *nonFatalErrors = [extractor extractBuildSettingsFromProject:badProjectURL error:&error];
    
    XCTAssertNil(nonFatalErrors);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, UnsupportedXcodeVersion);
    // "Unable to extract build settings from project ‘BadVersionNumber.xcodeproj"
    // "Project file format version ‘Xcode 9999.9’ is not supported."
    
}
@end
