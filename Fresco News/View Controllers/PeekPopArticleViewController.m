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
    
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"Add to Reading List" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        SSReadingList *readList = [SSReadingList defaultReadingList];
        NSError *error = [NSError new];
        
        BOOL status = [readList addReadingListItemWithURL:[NSURL URLWithString:self.title] title:self.title previewText:@"" error:&error];
        
        if (status) {
            NSLog(@"Added to Reading List");
        } else {
            NSLog(@"Could not add to Reading List");
        }
        
    }];
    
    UIPreviewAction *action3 = [UIPreviewAction actionWithTitle:@"Share" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self shareText:@"" andImage:nil andUrl:[[NSURL alloc] initWithString:self.title]];
    }];
    
    NSArray *actions = @[action1, action2, action3];
    
    return actions;
}

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
    [self.parentViewController presentViewController:activityController animated:YES completion:nil];
}


@end
