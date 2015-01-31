//
//  BuildSettingExtractorTests.m
//  BuildSettingExtractorTests
//
//  Created by James Dempsey on 9/9/14.
//  Copyright (c) 2014 Tapas Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BuildSettingExtractor.h"

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

@end
