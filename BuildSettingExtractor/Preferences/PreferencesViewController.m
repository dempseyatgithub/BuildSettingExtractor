//
//  PreferencesViewController.m
//  PreferencesPrototype
//
//  Created by James Dempsey on 1/31/20.
//  Copyright © 2020 James Dempsey. All rights reserved.
//

#import "PreferencesViewController.h"

@interface PreferencesViewController ()
@end

@implementation PreferencesViewController

- (void)viewWillAppear {
    [super viewWillAppear];
    [self updateWindowTitle];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self.view.window makeFirstResponder:nil];
}

- (void)updateWindowTitle {
    NSTabViewItem *selectedItem = self.tabViewItems[self.selectedTabViewItemIndex];
    self.view.window.title = selectedItem.label;
}

- (NSRect)windowFrameForViewController:(NSViewController *)viewController {
    NSRect contentRect = { NSZeroPoint, viewController.preferredContentSize };
    NSSize newSize = [self.view.window frameRectForContentRect:contentRect].size;
    NSRect windowFrame = self.view.window.frame;
    windowFrame.origin.y += windowFrame.size.height - newSize.height;
    windowFrame.size = newSize;
    return windowFrame;
}

- (void)transitionFromViewController:(NSViewController *)fromViewController toViewController:(NSViewController *)toViewController options:(NSViewControllerTransitionOptions)options completionHandler:(void (^)(void))completion {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        [self updateWindowTitle];
        NSRect windowFrame = [self windowFrameForViewController:toViewController];
        [self.view.window.animator setFrame:windowFrame display:false];
        NSViewControllerTransitionOptions options = NSViewControllerTransitionAllowUserInteraction | NSViewControllerTransitionCrossfade;
        [super transitionFromViewController:fromViewController toViewController:toViewController options: options completionHandler:completion];
    }];
}

@end
