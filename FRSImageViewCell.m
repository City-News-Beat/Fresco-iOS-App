//
//  FRSImageViewCell.m
//  fresco
//
//  Created by Philip Bernstein on 2/27/16.
//  Copyright © 2016 Philip Bernstein. All rights reserved.
//

#import "FRSImageViewCell.h"

@interface FRSImageViewCell()

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIView *coverView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIImageView *checkBox;
@property (nonatomic, weak) PHAsset *currentAsset;

@end

@implementation FRSImageViewCell

- (void)loadAsset:(PHAsset *)asset {
    self.currentAsset = asset;
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:asset
                       targetSize:CGSizeMake(150.0, 150.0)
                      contentMode:PHImageContentModeAspectFill
                          options:nil
                    resultHandler:^(UIImage *_Nullable result, NSDictionary *_Nullable info) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = result;
                        [self updateUIForAsset];
                      });
                    }];
}

- (void)updateUIForAsset { // always called on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
      if (_currentAsset.mediaType == PHAssetMediaTypeVideo) { // we need timing shown & updated
          self.timeLabel.hidden = NO;
          self.timeLabel.text = [self readableTimeForSeconds:_currentAsset.duration milliseconds:FALSE];
      } else { // we need timing hidden
          self.timeLabel.hidden = YES;
      }
    });
}

// made this @ overture hence the ms
- (NSString *)readableTimeForSeconds:(float)seconds milliseconds:(BOOL)showMilliseconds {
    // utility to convert 95 to 1:35 || 07 to :07; now has option to get down to thousands of a second
    int minutes = (int)seconds / 60;
    int remainder = fmodf(seconds, 60);

    int totalMilliseconds = seconds * 1000;

    totalMilliseconds -= minutes * 60 * 1000;
    totalMilliseconds -= remainder * 1000;

    NSString *secondsString = @"";
    NSString *minutesString = [NSString stringWithFormat:@"%d", minutes];

    if (minutes == 0)
        minutesString = @"";

    if (remainder < 10) {
        secondsString = @"0";
    }

    secondsString = [secondsString stringByAppendingString:[NSString stringWithFormat:@"%d", remainder]];

    // if we request milliseconds, we append it with a period on the string representation of milliseconds, to the hundreth of a second
    if (showMilliseconds && totalMilliseconds != 0) {
        if ([[NSString stringWithFormat:@"%d", totalMilliseconds] length] >= 1) {

            if (totalMilliseconds >= 100) {
                secondsString = [[secondsString stringByAppendingString:@"."] stringByAppendingString:[[NSString stringWithFormat:@"%d", totalMilliseconds] substringToIndex:1]];
            } else {
                secondsString = [[secondsString stringByAppendingString:@"."] stringByAppendingString:[[NSString stringWithFormat:@"0%d", totalMilliseconds] substringToIndex:2]];
            }
        } else {
            secondsString = [[secondsString stringByAppendingString:@"."] stringByAppendingString:[NSString stringWithFormat:@"%d", totalMilliseconds]];
        }
    }

    NSString *toReturn = [NSString stringWithFormat:@"%@:%@", minutesString, secondsString];
    if ([toReturn isEqualToString:@":00"]) {
        toReturn = @":01"; // this is specific for fresco
    }

    return toReturn;
}

- (void)selected:(BOOL)selected {
    if (selected) {
        self.checkBox.image = [UIImage imageNamed:@"picker-checkmark"];
    } else {
        self.checkBox.image = [UIImage imageNamed:@"checkboxBlankCircleOutline24W2"];
    }
    self.coverView.hidden = !selected;
}

@end
