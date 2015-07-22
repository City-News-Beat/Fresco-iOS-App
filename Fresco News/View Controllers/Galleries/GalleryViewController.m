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
@property (weak, nonatomic) IBOutlet UIView *storiesView;
@property (weak, nonatomic) IBOutlet UIView *articlesView;
@property (weak, nonatomic) IBOutlet UILabel *storiesLabel;
@property (weak, nonatomic) IBOutlet UITableView *storiesTable;
@property (weak, nonatomic) IBOutlet UILabel *articlesTitle;
@property (weak, nonatomic) IBOutlet UITableView *articlesTable;

/*
** Constraints
*/

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintArticleTableHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintStoriesTableHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintStoriesDiff;

@property (nonatomic, assign) BOOL bordersLaidOut;

@end

@implementation GalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *shareIcon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareGallery:)];
    
    [self.navigationItem setRightBarButtonItem:shareIcon];
    
    [self setUpGalleryInView];

}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:NO];

    [self disableVideo];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.constraintArticleTableHeight.constant = self.articlesTable.contentSize.height;
    self.constraintStoriesTableHeight.constant = self.storiesTable.contentSize.height;

    //Redraw Table Views
    [self.articlesTable.layer layoutIfNeeded];
    [self.articlesTable setNeedsLayout];
    [self.articlesTable layoutIfNeeded];
    [self.storiesTable.layer setNeedsLayout];
    [self.storiesTable.layer layoutIfNeeded];
    [self.storiesTable setNeedsLayout];
    [self.storiesTable layoutIfNeeded];
    [self.scrollView setNeedsLayout];
    [self.scrollView layoutIfNeeded];
    
    if (!self.bordersLaidOut) {
    
        /* Borders */
        if (self.gallery.articles.count != 0) {
            CALayer *topLayerArticles = [CALayer layer];
            topLayerArticles.frame = CGRectMake(0.0f, 0.0f, self.articlesTable.frame.size.width, 1.0f);
            topLayerArticles.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.12].CGColor;
            
            CALayer *bottomLayerArticles = [CALayer layer];
            bottomLayerArticles.frame = CGRectMake(0.0f, self.articlesTable.frame.size.height - 1.0f, self.articlesTable.frame.size.width, 1.0f);
            bottomLayerArticles.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.12].CGColor;
            
            [self.articlesTable.layer addSublayer:topLayerArticles];
            [self.articlesTable.layer addSublayer:bottomLayerArticles];
        }

        if (self.gallery.relatedStories.count != 0) {
            CALayer *topLayerStories = [CALayer layer];
            topLayerStories.frame = CGRectMake(0.0f, 0.0f, self.storiesTable.frame.size.width, 1.0f);
            topLayerStories.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.12].CGColor;
            
            CALayer *bottomLayerStories = [CALayer layer];
            bottomLayerStories.frame = CGRectMake(0.0f, self.storiesTable.frame.size.height - 1.0f, self.storiesTable.frame.size.width, 1.0f);
            bottomLayerStories.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.12].CGColor;
            
            [self.storiesTable.layer addSublayer:bottomLayerStories];
            [self.storiesTable.layer addSublayer:topLayerStories];
        }
    }
    
    self.bordersLaidOut = YES;
}

/*
** Constructs view from the Gallery object
*/

- (void)setUpGalleryInView{

    self.articlesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.storiesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.galleryView setGallery:self.gallery isInList:NO];
    
    self.caption.text = self.gallery.caption;
    
    FRSPost *post = (FRSPost *)[self.gallery.posts firstObject];
    
    self.byline.text = post.byline;
    self.timeAndPlace.text = [MTLModel relativeDateStringFromDate:self.gallery.createTime];
    
    if([post.address isKindOfClass:[NSString class]]){
        self.timeAndPlace.text = [NSString stringWithFormat:@"%@, %@", post.address, self.timeAndPlace.text];
    }
    
    if (self.gallery.articles.count == 0) {
        
        self.articlesView.hidden = YES;
        
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[articlesView(0)]"
                                                 options:0
                                                 metrics:nil
                                                   views: @{@"articlesView":self.articlesView}]];
        
    }
    
    if (self.gallery.relatedStories.count == 0) {
        
        self.storiesView.hidden = YES;
        
        self.constraintStoriesDiff.constant = 0;
        
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[storiesView(0)]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views: @{@"storiesView":self.storiesView}]];
        
        [self.storiesView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[storiesView(0)]"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views: @{@"storiesView":self.storiesTable}]];
    }
    
}

/*
** Opens Gallery View, with a passed gallery id
*/

- (void)openGalleryWithId:(NSString *)galleryId
{
    [[FRSDataManager sharedManager] getGallery:galleryId WithResponseBlock:^(id responseObject, NSError *error) {
        if (!error) {
            [self setGallery:responseObject];
        }
    }];
}

/*
** Initaites Activity Controller to share Gallery URL
*/

- (void)shareGallery:(id)sender
{
    NSString *string = [NSString stringWithFormat:@"https://fresconews.com/gallery/%@", self.gallery.galleryID];
    NSURL *URL = [NSURL URLWithString:string];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[string, URL]
                                                                                         applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController
                                            animated:YES
                                          completion:^{
                                              // ...
                                          }];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.storiesTable) {
        return self.gallery.relatedStories.count;
    }
    else if (tableView == self.articlesTable) {
        return self.gallery.articles.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.storiesTable) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"relatedStoryCell"];
        
        [((UILabel *)[cell viewWithTag:100]) setText:[[[self gallery] relatedStories] objectAtIndex:indexPath.row][@"title"]];
        
        //Check if it's not the last cell, then add a separator
        if (indexPath.row != self.gallery.relatedStories.count -1) {
            UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];/// change size as you need.
            separatorLineView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.12];// you can also put image here
            [cell.contentView addSubview:separatorLineView];
        }
        
        return cell;
    }
    else if (tableView == self.articlesTable) {
        
        FRSArticle *article = [[[self gallery] articles] objectAtIndex:indexPath.row];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"articleCell"];
        
        ((UILabel *)[cell viewWithTag:100]).text = article.title;
        
        [((UIImageView *)[cell viewWithTag:200]) setImageWithURL:article.URL];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //Check if it's not the last cell, then add a separator
        if (indexPath.row != self.gallery.articles.count -1) {
            UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)]; /// change size as you need.
            separatorLineView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.12]; // you can also put image here
            [cell.contentView addSubview:separatorLineView];
        }
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.storiesTable) {
        NSString *storyId = [[[self gallery] relatedStories] objectAtIndex:indexPath.row][@"_id"];
        [[FRSDataManager sharedManager] getStory:storyId withResponseBlock:^(id responseObject, NSError *error) {
            if (!error) {
                StoryViewController *storyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"storyViewController"];
                storyViewController.story = responseObject;
                [self.navigationController pushViewController:storyViewController animated:YES];
            }
        }];
    }
    else if (tableView == self.articlesTable) {
        FRSArticle *article = [[[self gallery] articles] objectAtIndex:indexPath.row];
        STKWebKitViewController *controller = [[STKWebKitViewController alloc] initWithURL:article.URL];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

@end