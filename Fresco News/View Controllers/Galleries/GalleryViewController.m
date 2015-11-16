//
//  GalleryViewController.m
//  FrescoNews
//
//  Created by Fresco News on 5/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "STKWebKitViewController.h"
#import "MTLModel+Additions.h"
#import "FRSDataManager.h"
#import "FRSPost.h"
#import "GalleryView.h"
#import "GalleryHeader.h"
#import "FRSArticle.h"
#import "GalleryViewController.h"
#import "PostCollectionViewCell.h"
#import "StoryViewController.h"
#import "GalleryTableViewCell.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

static CGFloat kSectionHeight = 40.0f;

static CGFloat kCellHeight = 44.0f;

@interface GalleryViewController ()  <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

/*
** View for posts
*/

@property (weak, nonatomic) IBOutlet GalleryView *galleryView;

/*
** Gallery View Properties, in order of appearance
*/

@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *galleryTable;
@property (weak, nonatomic) IBOutlet UIView *galleryHeader;

@end

@implementation GalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *shareIcon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareGallery:)];
    
    [self.navigationItem setRightBarButtonItem:shareIcon];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setUpGalleryInView];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:NO];

    [self.galleryView cleanUpVideoPlayer];
}


- (void)viewDidLayoutSubviews{

    [super viewDidLayoutSubviews];
    
    [self.galleryView setNeedsLayout];
    [self.galleryView layoutIfNeeded];
    
    CGFloat scrollViewHeight = 0.0f;
    
    CGRect newFrame = self.galleryTable.frame;
    
    newFrame.size.height = self.galleryTable.contentSize.height;
    
    self.galleryTable.frame = newFrame;
    
    [self.caption setNeedsLayout];
    [self.caption layoutIfNeeded];
    [self.caption sizeToFit];
    
    for (UIView *view in self.contentView.subviews) {
        
        scrollViewHeight += view.frame.size.height;
        
    }
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[posts(%f)]", scrollViewHeight + 44]
                                                                       options:0
                                                                       metrics:nil
                                                                         views: @{@"posts":self.contentView}]];

    
}

/**
 *  Constructs view from the Gallery object
 */

- (void)setUpGalleryInView{

    self.galleryTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.galleryTable.allowsSelection = YES;

    [self.galleryView setGallery:self.gallery shouldBeginPlaying:YES withDynamicAspectRatio:YES];
    
    self.caption.text = self.gallery.caption;

    GalleryHeader *galleryHeader = [[GalleryHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 32)];
    
    galleryHeader.gallery = self.gallery;

    [self.galleryHeader addSubview:galleryHeader];
}

/**
 *  Initiates Activity Controller to share Gallery URL
 *
 *  @param sender Sender property
 */

- (void)shareGallery:(id)sender
{
    NSString *string = [NSString stringWithFormat:@"%@/gallery/%@", BASE_URL, self.gallery.galleryID];
    NSURL *URL = [NSURL URLWithString:string];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[string, URL]
                                                                                         applicationActivities:nil];
    
    [activityViewController setCompletionWithItemsHandler: ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        
        if(completed){
            
            NSString *type;
            
            if(activityType == UIActivityTypePostToFacebook) type = @"Facebook";
            
            else if(activityType == UIActivityTypePostToTwitter) type = @"Facebook";
            
            else if(activityType == UIActivityTypeMail) type = @"Email";
            
            else if(activityType == UIActivityTypeCopyToPasteboard) type = @"Clipboard";
            
            else type = activityType;
            
            [Answers logShareWithMethod:type
                            contentName:@"Gallery"
                            contentType:@"gallery"
                              contentId:self.gallery.galleryID
                       customAttributes:@{@"location" : @"Gallery Detail"}];
        }
        
     }];
    
    [self.navigationController presentViewController:activityViewController
                                            animated:YES
                                          completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 0;
    
    if(self.gallery.relatedStories.count > 0)
        count++;
    if(self.gallery.articles.count > 0)
        count++;

    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Stories
    if (section == 0 && self.gallery.relatedStories.count > 0) {
        return self.gallery.relatedStories.count;
    }
    //Articles
    else if (section == 1 || self.gallery.relatedStories.count == 0) {
        return self.gallery.articles.count;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, tableView.frame.size.width, kSectionHeight)];
    [label setFont:[UIFont fontWithName:HELVETICA_NEUE_LIGHT size:13]];
    [label setTextColor:[UIColor textHeaderBlackColor]];
    
    if (section == 0 && self.gallery.relatedStories.count > 0)
        [label setText:@"RELATED STORIES"];
    else if (section == 1 || self.gallery.relatedStories.count == 0)
        [label setText:@"ARTICLES"];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0f, tableView.frame.size.width, kSectionHeight)];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Stories
    if (indexPath.section == 0 && self.gallery.relatedStories.count > 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"relatedStoryCell"];
        
        [((UILabel *)[cell viewWithTag:100]) setText:[self.gallery.relatedStories objectAtIndex:indexPath.row][@"title"]];
        
        //Check if it's not the last cell, then add a separator
        if (indexPath.row == 0) {
            
            CALayer *topLayerStories = [CALayer layer];
            topLayerStories.frame = CGRectMake(0.0f, 0.0f, self.galleryTable.frame.size.width, 1.0f);
            topLayerStories.backgroundColor = [UIColor cellSeparatorBlackColor].CGColor;
            
            [cell.contentView.layer addSublayer:topLayerStories];
            
        }
        
        //Add the custom separator
        CALayer *separatorLineView = [CALayer layer];
        separatorLineView.frame =CGRectMake(0, 43, tableView.frame.size.width, 1);
        separatorLineView.backgroundColor =[UIColor cellSeparatorBlackColor].CGColor;
        [cell.contentView.layer addSublayer:separatorLineView];
        
        return cell;
    }
    //Articles
    else if (indexPath.section == 1 || self.gallery.relatedStories.count == 0) {
        
        FRSArticle *article = [self.gallery.articles objectAtIndex:indexPath.row];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"articleCell"];
        
        ((UILabel *)[cell viewWithTag:100]).text = article.title;
        
        [((UILabel *)[cell viewWithTag:100]) sizeToFit];
        
        [cell.imageView setImageWithURL:article.favicon placeholderImage:[UIImage imageNamed:@"article"]];

        [cell.imageView.layer setCornerRadius:4];
        [cell.imageView.layer setMasksToBounds:YES];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //Check if it's not the last cell, then add a separator
        if (indexPath.row == 0) {
            
            CALayer *topLayerStories = [CALayer layer];
            topLayerStories.frame = CGRectMake(0.0f, 0.0f, self.galleryTable.frame.size.width, 1.0f);
            topLayerStories.backgroundColor = [UIColor cellSeparatorBlackColor].CGColor;
            
            [cell.contentView.layer addSublayer:topLayerStories];
            
        }
        
        //Add the custom separator
        CALayer *separatorLineView = [CALayer layer];
        separatorLineView.frame =CGRectMake(0, 43, tableView.frame.size.width, 1);
        separatorLineView.backgroundColor =[UIColor cellSeparatorBlackColor].CGColor;
        [cell.contentView.layer addSublayer:separatorLineView];
        
        return cell;
        
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Stories
    if (indexPath.section == 0 && self.gallery.relatedStories.count > 0) {
        NSString *storyId = [[[self gallery] relatedStories] objectAtIndex:indexPath.row][@"_id"];
        [[FRSDataManager sharedManager] getStory:storyId withResponseBlock:^(id responseObject, NSError *error) {
            if (!error) {
                StoryViewController *storyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"storyViewController"];
                storyViewController.story = responseObject;
                [self.navigationController pushViewController:storyViewController animated:YES];
            }
        }];
    }
    //Articles
    else if (indexPath.section == 1 || self.gallery.relatedStories.count == 0) {
        FRSArticle *article = [[[self gallery] articles] objectAtIndex:indexPath.row];
        STKWebKitViewController *controller = [[STKWebKitViewController alloc] initWithURL:article.URL];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{ return kCellHeight; }

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{ return kSectionHeight; }



@end