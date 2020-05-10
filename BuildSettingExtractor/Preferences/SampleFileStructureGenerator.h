//
//  SampleFileStructureGenerator.h
//  SampleOutlineView
//
//  Created by James Dempsey on 2/5/20.
//  Copyright © 2020 James Dempsey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface Item: NSObject
@property(copy) NSString *name;
@property NSMutableArray *children;
@property (readonly) BOOL isFolder;
@property (readonly) NSImage *icon;
- (instancetype)initWithName:(NSString *)name;
@end

@interface SampleFileStructureGenerator : NSObject
- (Item *)exampleDataForProjectName:(NSString *)projectName sharedName:(NSString *)sharedName wordSeparator:(NSString *)wordSeparator useSubfolders:(BOOL)useSubfolders useProjectFolder:(BOOL)useProjectFolder destinationFolderName:(NSString *)destinationFolderName;
@end

NS_ASSUME_NONNULL_END
