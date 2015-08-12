//
//  GalleryViewController.m
//  FrescoNews
//
//  Created by Fresco News on 5/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <STKWebKitViewController.h>
#import "MTLModel+Additions.h"
#import "FRSDataManager.h"
#import "FRSPost.h"
#import "GalleryView.h"
#import "FRSArticle.h"
#import "GalleryViewController.h"
#import "PostCollectionViewCell.h"
#import "StoryViewController.h"
#import "GalleryTableViewCell.h"

static CGFloat kSectionHeight = 40.0f;

static CGFloat kCellHeight = 44.0f;

@interface GalleryViewController ()  <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

/*
** View for posts
*/

@property (weak, nonatomic) IBOutlet GalleryView *galleryView;

/*
** Gallery Outlets, in order of appearance
*/

@property (weak, nonatomic) IBOutlet UILabel *timeAndPlace;
@property (weak, nonatomic) IBOutlet UILabel *byline;
@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *galleryTable;


@property (nonatomic, assign) BOOL bordersLaidOut;

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

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];

}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:NO];

    [self disableVideo];
}


- (void)viewDidLayoutSubviews{

    [super viewDidLayoutSubviews];
    

    [self.galleryView setNeedsLayout];
    [self.galleryView layoutIfNeeded];
    
    [self.caption sizeToFit];
    [self.caption setNeedsLayout];
    [self.caption layoutIfNeeded];
    
    CGFloat scrollViewHeight = 0.0f;
    
    CGRect newFrame = self.galleryTable.frame;
    
    newFrame.size.height = self.galleryTable.contentSize.height;
    
    self.galleryTable.frame = newFrame;
    
    for (UIView *view in self.contentView.subviews) {
        
        scrollViewHeight += view.frame.size.height;
        
    }
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[posts(%f)]", scrollViewHeight + 49 + 44]
                                                                       options:0
                                                                       metrics:nil
                                                                         views: @{@"posts":self.contentView}]];

    
}

/*
** Constructs view from the Gallery object
*/

- (void)setUpGalleryInView{

    self.galleryTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.galleryTable.allowsSelection = YES;

    [self.galleryView setGallery:self.gallery isInList:NO];
    
    self.caption.text = self.gallery.caption;
    
    FRSPost *post = (FRSPost *)[self.gallery.posts firstObject];
    
    self.byline.text = post.byline;
    
    self.timeAndPlace.text = [MTLModel relativeDateStringFromDate:self.gallery.createTime];
    
    if ([post.address length] > 0)
        self.timeAndPlace.text = [NSString stringWithFormat:@"%@, %@", post.address, self.timeAndPlace.text];
}

/*
** Initiates Activity Controller to share Gallery URL
*/

- (void)shareGallery:(id)sender
{
    NSString *string = [NSString stringWithFormat:@"%@/gallery/%@", PRODUCTION_BASE_URL, self.gallery.galleryID];
    NSURL *URL = [NSURL URLWithString:string];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[string, URL]
                                                                                         applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController
                                            animated:YES
                                          completion:nil];
}

/*
** Disables currently playing video, check in viewDidDisappear
*/

- (void)disableVideo
{
    
    if(self.galleryView.sharedPlayer != nil){
        [self.galleryView.sharedPlayer pause];
        self.galleryView.sharedPlayer = nil;
        [self.galleryView.sharedLayer removeFromSuperlayer];
    }
    
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

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, tableView.frame.size.width, kSectionHeight)];
    [label setFont:[UIFont fontWithName:HELVETICA_NEUE_LIGHT size:13]];
    
    if (section == 0 && self.gallery.relatedStories.count > 0)
        [label setText:@"RELATED STORIES"];
    else if (section == 1 || self.gallery.relatedStories.count == 0)
        [label setText:@"ARTICLES"];
    
    [label setTextColor:[UIColor textHeaderBlackColor]];
    
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
        
        [((UILabel *)[cell viewWithTag:100]) setText:[self.gallery.relatedStories objectAtIndex:0][@"title"]];
        
        //Check if it's not the last cell, then add a separator
        if (indexPath.row == 0) {
            
            CALayer *topLayerStories = [CALayer layer];
            topLayerStories.frame = CGRectMake(0.0f, 0.0f, self.galleryTable.frame.size.width, 1.0f);
            topLayerStories.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.12].CGColor;
            
            [cell.contentView.layer addSublayer:topLayerStories];
            
        }
        
        CALayer *separatorLineView = [CALayer layer];
        separatorLineView.frame =CGRectMake(0, 43, tableView.frame.size.width, 1);
        separatorLineView.backgroundColor =[UIColor colorWithRed:0 green:0 blue:0 alpha:.12].CGColor;
        [cell.contentView.layer addSublayer:separatorLineView];
        
        return cell;
    }
    //Articles
    else if (indexPath.section == 1 || self.gallery.relatedStories.count == 0) {
        
        FRSArticle *article = [self.gallery.articles objectAtIndex:0];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"articleCell"];
        
        ((UILabel *)[cell viewWithTag:100]).text = article.title;
        
        [cell.imageView setImageWithURL:article.URL placeholderImage:[UIImage imageNamed:@"article"]];

        [cell.imageView.layer setCornerRadius:4];
        [cell.imageView.layer setMasksToBounds:YES];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //Check if it's not the last cell, then add a separator
        if (indexPath.row == 0) {
            
            CALayer *topLayerStories = [CALayer layer];
            topLayerStories.frame = CGRectMake(0.0f, 0.0f, self.galleryTable.frame.size.width, 1.0f);
            topLayerStories.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.12].CGColor;
            
            [cell.contentView.layer addSublayer:topLayerStories];
            
        }
        
        CALayer *separatorLineView = [CALayer layer];
        separatorLineView.frame =CGRectMake(0, 43, tableView.frame.size.width, 1);
        separatorLineView.backgroundColor =[UIColor colorWithRed:0 green:0 blue:0 alpha:.12].CGColor;
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