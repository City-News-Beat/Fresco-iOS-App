//
//  GalleryViewController.m
//  FrescoNews
//
//  Created by Elmir Kouliev on 5/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "MTLModel+Additions.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <PBWebViewController.h>
#import "FRSPost.h"
#import "FRSArticle.h"
#import "GalleryViewController.h"
#import "PostCollectionViewCell.h"


@interface GalleryViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeAndPlace;

@property (weak, nonatomic) IBOutlet UILabel *byline;


@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UITableView *storiesTable;
@property (weak, nonatomic) IBOutlet UITableView *articlesTable;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionPosts;
@property (weak, nonatomic) IBOutlet UIPageControl *postsPageControl;
@end

@implementation GalleryViewController


- (id)init
{
    
    if (self = [super init]) {

    }
    
    return self;
    
}


- (void)viewDidLoad
{
    self.postsPageControl.numberOfPages = 0;
    
    self.caption.text = self.gallery.caption;
    
    self.timeAndPlace.text = [MTLModel relativeDateStringFromDate:self.gallery.createTime];
    
    self.byline.text = ((FRSPost *)[self.gallery.posts firstObject]).byline;


}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.storiesTable){
        return 0;
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
        
        [storyTitle setText:@"Test"];
        
        return cell;
        
    }
    else if(tableView == self.articlesTable){
        
        FRSArticle *article = [[[self gallery] articles] objectAtIndex:indexPath.row];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"articleCell"];
        
        UILabel *articleTitle = (UILabel *)[cell viewWithTag:100];
        
        UIImageView *articleImage = (UIImageView *)[cell viewWithTag:200];
        
        articleTitle.text = article.name;
        [articleImage setImageWithURL:article.URL];
        
    }
    
    return 0;
    
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == self.storiesTable){
        

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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [self.gallery.posts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PostCollectionViewCell identifier] forIndexPath:indexPath];
    
    cell.post = [self.gallery.posts objectAtIndex:indexPath.item];
    cell.backgroundColor = [UIColor colorWithHex:[VariableStore sharedInstance].colorBackground];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.bounds.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}


#pragma mark - ScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSIndexPath *index = [[self.collectionPosts indexPathsForVisibleItems] lastObject];
    
    self.postsPageControl.currentPage = index.item;

}

@end
