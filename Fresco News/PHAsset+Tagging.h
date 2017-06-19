//
//  PHAsset+Tagging.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Photos/Photos.h>
#import "FRSFileTag.h"

@interface PHAsset (Tagging)

@property (nonatomic, copy) FRSFileTag *fileTag;

@end
