//
//  FRSFileTag.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSCameraConstants.h"

@interface FRSFileTag : NSObject

@property(readonly, nonatomic, strong) NSString *name;
@property(readonly, nonatomic, assign) FRSCaptureMode captureMode;

- (instancetype)initWithName:(NSString *)name;

@end
