//
//  BuildSettingInfoSource.h
//  BuildSettingExtractor
//
//  Created by James Dempsey on 10/9/19.
//  Copyright © 2019 Tapas Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BuildSettingInfoSourceStyle) {
    BuildSettingInfoSourceStyleStandard = 100,
};

NS_ASSUME_NONNULL_BEGIN

@interface BuildSettingInfoSource : NSObject

@property (nullable) NSURL *resolvedURL; // nil if unresolved
@property NSInteger resolvedVersion; // -1 if unresolved

// On success, will return a BuildSettingInfoSource instance with valid values for resolvedURL and resolvedVersion.
//
// Even on success, error value may be present if resolved value was not from the expected source.
// For example, if a custom URL was provided but not found the resolved info source may be the version of Xcode
// in its standard location.
//
// On failure will return nil and an error if unable to resolve a build setting info source.

+ (nullable BuildSettingInfoSource *)resolvedBuildSettingInfoSourceWithStyle:(BuildSettingInfoSourceStyle)style customURL:(nullable NSURL *)customURL error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
