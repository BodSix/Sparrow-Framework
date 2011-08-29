//
//  SPRenderable.h
//  beastie
//
//  Created by Cory Osborn on 8/22/11.
//  Copyright 2011 BodSix, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPRenderSupport.h"

@protocol SPRenderable <NSObject>
-(void)render:(SPRenderSupport*)support;
-(float)alpha;
-(void)setAlpha:(float)pAlpha;
@end
