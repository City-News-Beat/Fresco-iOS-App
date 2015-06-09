//
//  GalleryViewController.m
//  FrescoNews
//
//  Created by Elmir Kouliev on 5/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <PBWebViewController.h>
#import "MTLModel+Additions.h"
#import "FRSDataManager.h"
#import "FRSPost.h"
#import "GalleryView.h"
#import "FRSArticle.h"
#import "GalleryViewController.h"
#import "PostCollectionViewCell.h"
#import "StoryViewController.h"

@interface GalleryViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet GalleryView *galleryView;

@property (weak, nonatomic) IBOutlet UILabel *timeAndPlace;

@property (weak, nonatomic) IBOutlet UILabel *byline;

@property (weak, nonatomic) IBOutlet UILabel *caption;

@property (weak, nonatomic) IBOutlet UIView *storiesView;

@property (weak, nonatomic) IBOutlet UIView *articlesView;

@property (weak, nonatomic) IBOutlet UILabel *storiesLabel;

@property (weak, nonatomic) IBOutlet UITableView *storiesTable;

@property (weak, nonatomic) IBOutlet UILabel *articlesTitle;

@property (weak, nonatomic) IBOutlet UITableView *articlesTable;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintArticleTableHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintStoriesTableHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintStoriesDiff;

@end

@implementation GalleryViewController

- (void)viewDidLoad
{
    
    [self setUpGallery];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    // just add this line to the end of this method or create it if it does not exist

}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //Redraw Table Views
    [self.articlesTable setNeedsLayout];
    [self.articlesTable layoutIfNeeded];
    [self.storiesTable setNeedsLayout];
    [self.storiesTable layoutIfNeeded];
    
    //
    self.constraintArticleTableHeight.constant = self.articlesTable.contentSize.height;
    self.constraintStoriesTableHeight.constant = self.storiesTable.contentSize.height;
    
    [self.storiesView setNeedsLayout];
    [self.storiesView layoutIfNeeded];
    
    [self.scrollView layoutIfNeeded];
    
}


- (void)setUpGallery{
    
    self.galleryView.gallery = self.gallery;
    
    self.caption.text = self.gallery.caption;
    
    self.timeAndPlace.text = [MTLModel relativeDateStringFromDate:self.gallery.createTime];
    
    self.byline.text = ((FRSPost *)[self.gallery.posts firstObject]).byline;

    if(self.gallery.articles.count == 0){

        self.articlesView.hidden = YES;
    
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[articlesView(0)]"
                                                 options:0
                                                 metrics:nil
                                                   views: @{@"articlesView":self.articlesView}]];

    }
    if(self.gallery.relatedStories.count == 0){
    
        self.storiesView.hidden = YES;
    
        self.constraintStoriesDiff.constant = 0;

        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[storiesView(0)]"
                                                 options:0
                                                 metrics:nil
                                                   views: @{@"storiesView":self.storiesView}]];
    
        [self.storiesView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[storiesView(0)]"
                                                 options:0
                                                 metrics:nil
                                                   views: @{@"storiesView":self.storiesTable}]];
    }


}

- (void)openGalleryWithId:(NSString *)galleryId{

    [[FRSDataManager sharedManager] getGallery:galleryId WithResponseBlock:^(id responseObject, NSError *error) {
        
        if (!error) {
            
            [self setGallery:responseObject];
            
            [self setUpGallery];
            
        }
        
    }];

}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.storiesTable){
        return self.gallery.relatedStories.count;
    }
    else if(tableView == self.articlesTable){
        
        return self.gallery.articles.count;
        
    }
    
    return 0;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == self.storiesTable){
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"relatedStoryCell"];
        
        UILabel *storyTitle = (UILabel *)[cell viewWithTag:100];
        
        [storyTitle setText:[[[self gallery] relatedStories] objectAtIndex:indexPath.row][@"title"]];
        
        return cell;
        
    }
    else if(tableView == self.articlesTable){
        
        FRSArticle *article = [[[self gallery] articles] objectAtIndex:indexPath.row];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"articleCell"];
        
        UILabel *articleTitle = (UILabel *)[cell viewWithTag:100];
        
        UIImageView *articleImage = (UIImageView *)[cell viewWithTag:200];
        
        articleTitle.text = article.title;
        
        [articleImage setImageWithURL:article.URL];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
        
    }
    
    return 0;
    
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == self.storiesTable){
        
        NSString *storyId = [[[self gallery] relatedStories] objectAtIndex:indexPath.row][@"_id"];
        
        [[FRSDataManager sharedManager] getStory:storyId withResponseBlock:^(id responseObject, NSError *error) {
            
            if (!error) {
                
                StoryViewController *storyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"storyViewController"];
                
                storyViewController.story = responseObject;
                
                [self.navigationController pushViewController:storyViewController animated:YES];
                
            }
            
        }];
        
        

    }
    else if(tableView == self.articlesTable){
        
        FRSArticle *article = [[[self gallery] articles] objectAtIndex:indexPath.row];
        
        //Push to web view
        PBWebViewController *webViewController = [[PBWebViewController alloc] init];
        webViewController.URL = article.URL;
        
        //        PBSafariActivity *activity = [[PBSafariActivity alloc] init];
        //        webViewController.applicationActivities = @[activity];
        //
        [[self navigationController] pushViewController:webViewController animated:YES];
        
        
    }


}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0f;
}






@end
