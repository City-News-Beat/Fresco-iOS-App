//
//  FRSGalleryExpandedViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSGalleryExpandedViewController.h"

#import "FRSGallery.h"
#import "FRSGalleryView.h"

@interface FRSGalleryExpandedViewController () <UIScrollViewDelegate, FRSGalleryViewDataSource>

@property (strong, nonatomic) FRSGallery *gallery;

@property (strong, nonatomic) FRSGalleryView *galleryView;

@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation FRSGalleryExpandedViewController

-(instancetype)initWithGallery:(FRSGallery *)gallery{
    self = [super init];
    if (self){
        self.gallery = gallery;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    
    // Do any additional setup after loading the view.
}

-(void)configureUI{
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self configureNavigationBar];
    [self configureScrollView];
    [self configureGalleryView];
    [self configureArticles];
    [self configureComments];
    [self configureActionBar];
}

-(void)configureNavigationBar{
    [super configureNavigationBar];
    self.navigationItem.title = @"GALLERY";
}

-(void)configureScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}

-(void)configureGalleryView{
    self.galleryView = [[FRSGalleryView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 500) gallery:self.gallery dataSource:self];
    [self.scrollView addSubview:self.galleryView];
}

-(void)configureArticles{
    
}

-(void)configureComments{
    
}

-(void)configureActionBar{
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FRSGalleryView Delegate

-(BOOL)shouldHaveActionBar{
    return NO;
}

-(BOOL)shouldHaveTextLimit {
    return NO;
}

-(NSInteger)heightForImageView{
    return 300;
}

#pragma mark - UIScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollViewDidScroll:scrollView];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
