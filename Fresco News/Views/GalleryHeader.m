//
//  GalleryHeader.m
//  FrescoNews
//
//  Created by Fresco News on 3/17/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "GalleryHeader.h"
#import "FRSPost.h"
#import "FRSGallery.h"
#import "GalleryTableViewCell.h"

@interface GalleryHeader ()

@property (strong, nonatomic) UILabel *labelPlace;

@property (strong, nonatomic) UILabel *labelByLineAndTime;

@property (strong, nonatomic) NSLayoutConstraint *trailingSpaceByline;

@property (strong, nonatomic) NSLayoutConstraint *leadingSpacePlace;

@end

static NSString * const kCellIdentifier = @"GalleryHeader";

@implementation GalleryHeader

+ (NSString *)identifier
{
    return kCellIdentifier;
}

- (id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    
    if(self){
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGalleryHeader:) name:NOTIF_GALLERY_HEADER_UPDATE object:nil];
        
        self.backgroundColor = [UIColor whiteColor];
        CGRect labelFrame = CGRectMake(0, 0, 0, 12);
        
        self.labelPlace = [[UILabel alloc] initWithFrame:labelFrame];
        self.labelPlace.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.labelPlace setContentCompressionResistancePriority:UILayoutPriorityDefaultLow
                                                                 forAxis:UILayoutConstraintAxisHorizontal];
       
        self.labelByLineAndTime = [[UILabel alloc] initWithFrame:labelFrame];
        self.labelByLineAndTime.textAlignment = NSTextAlignmentRight;
        [self.labelByLineAndTime setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh
                                                 forAxis:UILayoutConstraintAxisHorizontal];
        
        for (UILabel *label in @[self.labelByLineAndTime, self.labelPlace]) {
            
            label.font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:12];
            label.textColor = [UIColor textHeaderBlackColor];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:label];
            
        }
        
        /* Leading Space for Place */
        self.leadingSpacePlace = [NSLayoutConstraint
                                  constraintWithItem:self.labelPlace
                                  attribute:NSLayoutAttributeLeading
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self
                                  attribute:NSLayoutAttributeLeading
                                  multiplier:1.0
                                  constant:16.0];

        /* Trailing space for ByLine */
        self.trailingSpaceByline = [NSLayoutConstraint
                                    constraintWithItem:self.labelByLineAndTime
                                    attribute:NSLayoutAttributeTrailing
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                    attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0
                                    constant:-16.0];

        /* Horizontal Space */
        NSLayoutConstraint *horizontalSpaceBetween = [NSLayoutConstraint
                                                      constraintWithItem:self.labelByLineAndTime
                                                      attribute:NSLayoutAttributeLeft
                                                      relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                      toItem:self.labelPlace
                                                      attribute:NSLayoutAttributeRight
                                                      multiplier:1.0
                                                      constant:16.0];

        
        /* Top Space for Place Label */
        NSLayoutConstraint *topSpaceTime = [NSLayoutConstraint
                                            constraintWithItem:self.labelPlace
                                            attribute:NSLayoutAttributeTop
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                            attribute:NSLayoutAttributeTop
                                            multiplier:1.0
                                            constant:8.0];
        
        /* Top Space for Byline */
        NSLayoutConstraint *topSpaceByline = [NSLayoutConstraint
                                              constraintWithItem:self.labelByLineAndTime
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                              toItem:self
                                              attribute:NSLayoutAttributeTop
                                              multiplier:1.0
                                              constant:8.0];
        
        [self addConstraint:self.leadingSpacePlace];
        [self addConstraint:self.trailingSpaceByline];
        [self addConstraint:horizontalSpaceBetween];
        [self addConstraint:topSpaceTime];
        [self addConstraint:topSpaceByline];
        
    }
    
    return self;

}


#pragma mark - Notification Center Delegate

/*
** Runs update on gallery header with passed notif object
*/

- (void)updateGalleryHeader:(NSNotification *)notif{
    
    //Check if the notification is in a valid format
    if(notif.object[@"postIndex"] && notif.object[@"gallery"]){
    
        if([notif.object[@"gallery"] isEqualToString:self.gallery.galleryID]){
         
            [self galleryHeaderUpdateAnimationWithIndex:[(NSNumber *)notif.object[@"postIndex"] integerValue]];
            
        }
    }
}

- (void)galleryHeaderUpdateAnimationWithIndex:(NSInteger)postIndex{

    FRSPost *post = (FRSPost *)self.gallery.posts[postIndex];
    
    if(!post) return;
    
    NSString *bylineAndTime = [NSString stringWithFormat:@"%@  %@", post.byline, [MTLModel relativeDateStringFromDate:self.gallery.createTime]];
    
    if(![self.labelPlace.text isEqual:post.address]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                
                self.labelPlace.alpha = 0;
                
            } completion:^(BOOL finished) {
                
                self.labelPlace.text = post.address;
                
                [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    
                    self.labelPlace.alpha = 1;
                    
                } completion:nil];
                
            }];
            
        });
        
    }
    if(![self.labelByLineAndTime.text isEqual:bylineAndTime]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                
                self.labelByLineAndTime.alpha = 0;
                
            } completion:^(BOOL finished) {
                
                self.labelByLineAndTime.text = bylineAndTime;
                
                [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    
                    self.labelByLineAndTime.alpha = 1;
                    
                } completion:nil];
                
            }];
            
        });
        
    }

}

/*
** Updates header view with passed post
*/

- (void)setHeaderWithPost:(FRSPost *)post
{
    
    if(![post.address isEqualToString:@"No Location"])
        self.labelPlace.text =  post.address;
    else
        self.labelPlace.text = @"";
    
    NSString *bylineAndTime = [NSString stringWithFormat:@"%@  %@", post.byline, [MTLModel relativeDateStringFromDate:self.gallery.createTime]];

    self.labelByLineAndTime.text = bylineAndTime;
    
}

- (void)setGallery:(FRSGallery *)passedGallery
{
    
    _gallery = passedGallery;
    
    FRSPost *post = (FRSPost *)[self.gallery.posts firstObject];
    
    [self setHeaderWithPost:post];

}

@end
