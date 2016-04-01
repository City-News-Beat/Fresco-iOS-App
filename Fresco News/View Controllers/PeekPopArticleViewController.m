//
//  PeekPopArticleViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 4/1/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "PeekPopArticleViewController.h"

@interface PeekPopArticleViewController () <UIViewControllerPreviewingDelegate>

@end

@implementation PeekPopArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"Open in Safari" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"Action 1");
    }];
    
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"Add to Reading List" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"Action 2");
    }];
    
    UIPreviewAction *action3 = [UIPreviewAction actionWithTitle:@"Share" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"Action 3");
    }];
    
    NSArray *actions = @[action1, action2, action3];
    
    return actions;
}


@end
