//
//  FRSGalleryFooterView.m
//  Fresco
//
//  Created by Omar Elfanek on 1/16/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryFooterView.h"

#define LABEL_HEIGHT 20
#define LABEL_PADDING 8

@interface FRSGalleryFooterView () <FRSUserViewDelegate>
@property (strong, nonatomic) UILabel *updatedAtLabel;
@property (strong, nonatomic) UILabel *postedAtLabel;


@end

@implementation FRSGalleryFooterView

- (instancetype)initWithFrame:(CGRect)frame gallery:(FRSGallery *)gallery delegate:(id<FRSGalleryFooterViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    
    self.delegate = delegate;
    
    if (self) {        
        [self configureWithGallery:gallery];
    }
    return self;
}


/**
 Configures the view from the given gallery.

 @param gallery The gallery to configure the view with.
 */
-(void)configureWithGallery:(FRSGallery *)gallery {
    [self configureTimestampsFromGallery:gallery];
    [self configureCreatorFromGallery:gallery];
}


/**
 Creates and adds two labels that display when the gallery was posted and when the given gallery was updated.
 
 @param gallery An FRSGallery where postedAt and editedAt will be pulled from.
 */
- (void)configureTimestampsFromGallery:(FRSGallery *)gallery {
    self.updatedAtLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.frame.size.width, LABEL_HEIGHT)];
    self.updatedAtLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.updatedAtLabel.text = [NSString stringWithFormat:@"Updated %@ at %@", [FRSDateFormatter dateDifference:gallery.editedDate withAbbreviatedMonth:YES], [FRSDateFormatter formattedTimestampFromDate:gallery.editedDate]];
    self.updatedAtLabel.textColor = [UIColor frescoMediumTextColor];
    [self addSubview:self.updatedAtLabel];
    
    self.postedAtLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, self.updatedAtLabel.frame.origin.y + LABEL_HEIGHT + LABEL_PADDING, self.frame.size.width, LABEL_HEIGHT)];
    self.postedAtLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.postedAtLabel.text = [NSString stringWithFormat:@"Posted %@ at %@ by:", [FRSDateFormatter dateDifference:gallery.createdDate withAbbreviatedMonth:YES], [FRSDateFormatter formattedTimestampFromDate:gallery.createdDate]];
    self.postedAtLabel.textColor = [UIColor frescoMediumTextColor];
    [self addSubview:self.postedAtLabel];
}



/**
 Creates an instance of FRSUserView and adds it below the postedAt and editedAt labels.

 @param gallery An FRSGallery where the creator will be pulled from.
 */
- (void)configureCreatorFromGallery:(FRSGallery *)gallery {
    if (!gallery.creator) {
        return;
    }
    
    self.userView = [[FRSUserView alloc] initWithUser:gallery.creator];
    self.userView.delegate = self;
    self.userView.frame = CGRectMake(0, self.postedAtLabel.frame.origin.y + LABEL_HEIGHT, self.frame.size.width, self.userView.calculatedHeight);
    [self addSubview:self.userView];
}



/**
 Calculates the total height of the view by adding the height of the labels and the userView.
 
 @return Returns the height of the view.
 */
-(NSInteger)calculatedHeight {
    return self.updatedAtLabel.frame.size.height + self.postedAtLabel.frame.size.height + self.userView.frame.size.height;
}


#pragma mark - FRSUserViewDelegate

-(void)userAvatarTapped {
    if (self.delegate) {
        [self.delegate userAvatarTapped];
    }
}










@end
