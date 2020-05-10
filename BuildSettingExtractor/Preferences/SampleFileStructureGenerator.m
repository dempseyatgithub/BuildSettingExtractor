//
//  SampleFileStructureGenerator.m
//  SampleOutlineView
//
//  Created by James Dempsey on 2/5/20.
//  Copyright © 2020 James Dempsey. All rights reserved.
//

#import "SampleFileStructureGenerator.h"

@implementation Item
- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        self.name = name;
        self.children = [[NSMutableArray alloc] init];
    }
    return self;
}
- (BOOL)isFolder {
    return self.children.count > 0;
}
- (NSImage *)icon {
    NSString *iconName = self.isFolder ? @"folder" : @"config_file";
    return [NSImage imageNamed:iconName];
}
@end

@interface NSString (TPS_SpaceReplacement)
    -(NSString *)tps_stringReplacingSpacesWithString:(NSString *)separator;
@end
@implementation NSString (TPS_SpaceReplacement)
-(NSString *)tps_stringReplacingSpacesWithString:(NSString *)separator {
    return [self stringByReplacingOccurrencesOfString:@" " withString:separator];
    }
@end

@implementation SampleFileStructureGenerator
- (Item *)exampleDataForProjectName:(NSString *)projectName sharedName:(NSString *)sharedName wordSeparator:(NSString *)wordSeparator useSubfolders:(BOOL)useSubfolders useProjectFolder:(BOOL)useProjectFolder destinationFolderName:(NSString *)destinationFolderName {
    
    NSArray *sortedConfigs = [@[[sharedName tps_stringReplacingSpacesWithString:wordSeparator], @"Debug", @"Release"] sortedArrayUsingSelector:@selector(localizedCompare:)];
    NSArray *sortedTargets = [@[[projectName tps_stringReplacingSpacesWithString:wordSeparator], @"MyApp", @"MyAppTests"] sortedArrayUsingSelector:@selector(localizedCompare:)];
    
    Item *rootItem = [[Item alloc] initWithName:@"Root"];
    
    Item *destinationItem = [[Item alloc] initWithName:destinationFolderName];
    [rootItem.children addObject:destinationItem];
    
    for (NSString *targetName in sortedTargets) {
        BOOL skipProjectFolder = [targetName isEqualToString:projectName] && !useProjectFolder;
        if (useSubfolders && !skipProjectFolder) {
            Item *targetFolderItem = [[Item alloc] initWithName:targetName];
            [self appendChildrenToItem:targetFolderItem withRootName:targetName configNames:sortedConfigs wordSeparator:wordSeparator];
            [destinationItem.children addObject:targetFolderItem];

        } else {
            [self appendChildrenToItem:destinationItem withRootName:targetName configNames:sortedConfigs wordSeparator:wordSeparator];
        }
    }

    return rootItem;
}

- (NSString *)nameForRootName:(NSString *)rootName separator:(NSString *)separator configName:(NSString *)configName {
    return [NSString stringWithFormat:@"%@%@%@.xcconfig", rootName, separator, configName];
}

- (void)appendChildrenToItem:(Item *)item withRootName:(NSString *)rootName configNames:(NSArray *)configNames wordSeparator:(NSString *)wordSeparator {
    for (NSString * configName in configNames) {
        NSString *fileName = [self nameForRootName:rootName separator:wordSeparator configName:configName];
        Item *newItem = [[Item alloc] initWithName:fileName];
        [item.children addObject:newItem];
    }
}

@end
