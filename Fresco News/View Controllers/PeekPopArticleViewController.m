//
//  PeekPopArticleViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 4/1/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "PeekPopArticleViewController.h"
#import "FRSArticle.h"
#import <SafariServices/SafariServices.h>

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
        
        NSURL *url = [NSURL URLWithString:self.title];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"Share" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        [self shareText:@"" andImage:nil andUrl:[[NSURL alloc] initWithString:self.title]];

    }];
    
    NSArray *actions = @[action1, action2];
    
    return actions;
}

//-(NSArray<id> *)previewActionItems {
//    
//    // setup a list of preview actions
//    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"Action 1" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
//        NSLog(@"Action 1 triggered");
//    }];
//    
//    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"Destructive Action" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
//        NSLog(@"Destructive Action triggered");
//    }];
//    
//    UIPreviewAction *action3 = [UIPreviewAction actionWithTitle:@"Selected Action" style:UIPreviewActionStyleSelected handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
//        NSLog(@"Selected Action triggered");
//    }];
//    
//    // add them to an arrary
//    NSArray *actions = @[action1, action2, action3];
//    
//    UIPreviewActionGroup *group1 = [UIPreviewActionGroup actionGroupWithTitle:@"Action Group" style:UIPreviewActionStyleDefault actions:actions];
//    NSArray *group = @[group1];
//    
//    // and return them
//    return group;
//}

-(void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url {
    
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:activityController animated:YES completion:nil];
}


@end
