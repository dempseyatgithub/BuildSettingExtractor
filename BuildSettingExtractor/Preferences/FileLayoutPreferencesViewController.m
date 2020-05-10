//
//  FileLayoutPreferencesViewController.m
//  BuildSettingExtractor
//
//  Created by James Dempsey on 2/14/20.
//  Copyright © 2020 Tapas Software. All rights reserved.
//

#import "FileLayoutPreferencesViewController.h"
#import "AppConstants+Categories.h"
#import "SampleFileStructureGenerator.h"


@interface FileLayoutPreferencesViewController () <NSOutlineViewDataSource, NSOutlineViewDelegate>
@property (weak) IBOutlet NSOutlineView *outlineView;
@property Item *rootItem;
@end

@implementation FileLayoutPreferencesViewController

- (NSSize)preferredContentSize {
    return NSMakeSize(744.0, 352.0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *defaultKeys = @[TPSOutputFileNameShared, TPSOutputFileNameProject, TPSOutputFileNameSeparator, TPSTargetFoldersEnabled, TPSProjectFolderEnabled, TPSDestinationFolderName];
    for (NSString *key in defaultKeys) {
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:key options:0 context:nil];
    }
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [self updateOutlineView];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [self updateOutlineView];
}

- (void)updateOutlineView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sharedName = [defaults stringForKey:TPSOutputFileNameShared];
    NSString *projectName = [defaults stringForKey:TPSOutputFileNameProject];
    NSString *separator = [defaults stringForKey:TPSOutputFileNameSeparator];
    BOOL targetFoldersEnabled = [defaults boolForKey:TPSTargetFoldersEnabled];
    BOOL projectFolderEnabled = [defaults boolForKey:TPSProjectFolderEnabled];
    NSString *destinationFolderName = [defaults stringForKey:TPSDestinationFolderName];
    
    self.rootItem = [[[SampleFileStructureGenerator alloc] init] exampleDataForProjectName:projectName sharedName:sharedName wordSeparator:separator useSubfolders:targetFoldersEnabled useProjectFolder:projectFolderEnabled destinationFolderName:destinationFolderName];
    [self.outlineView reloadData];
    [self.outlineView expandItem:nil expandChildren:YES];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    if (!item) { return self.rootItem.children.count; }
    else { return ((Item *)item).children.count; }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item{
    if (!item) { return self.rootItem.children[index]; }
    else { return ((Item *)item).children[index]; }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if (!item) { return self.rootItem.isFolder; }
    else { return ((Item *)item).isFolder; }
}

- (nullable NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item {
    Item *outlineItem = item;
    NSTableCellView *cell = [outlineView makeViewWithIdentifier:@"OutlineCell" owner:nil];
    cell.textField.stringValue = outlineItem.name;
    cell.imageView.image = outlineItem.icon;
    return cell;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return NO;
}

@end
