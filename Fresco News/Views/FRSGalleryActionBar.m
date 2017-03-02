//
//  FRSGalleryActionBar.m
//  Fresco
//
//  Created by Omar Elfanek on 3/2/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryActionBar.h"
#import "FRSGallery.h"

#define HEIGHT 44

@interface FRSGalleryActionBar ()

@end

@implementation FRSGalleryActionBar

-(instancetype)initWithFrame:(CGRect)frame gallery:(FRSGallery *)gallery {
    self = [super init];
    
    if (self) {
        
        // Configure nib
//        self = [[[NSBundle mainBundle] loadNibNamed:@"FRSActionBar" owner:self options:nil] objectAtIndex:0];
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, [UIScreen mainScreen].bounds.size.width, HEIGHT);
        self.backgroundColor = [UIColor redColor];
        
        self.gallery = gallery;
    }
    
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
}


-(void)loadGallery:(FRSGallery *)gallery {
    [self updateActionBarFromGallery:gallery];
}


- (void)updateActionBarFromGallery:(FRSGallery *)gallery {
    [super handleRepostState:[gallery valueForKey:@"reposted"]];
    [super handleRepostAmount:[[gallery valueForKey:@"reposts"] integerValue]];
    
    [super handleHeartAmount:[[gallery valueForKey:@"likes"] integerValue]];
    [super handleHeartState:[gallery valueForKey:@"liked"]];
}

@end
