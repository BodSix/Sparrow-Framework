//
// SHClippedSprite.h
// Sparrow
//
// Created by Shilo White on 5/30/11.
// Copyright 2011 Shilocity Productions. All rights reserved.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the Simplified BSD License.
//
// Modified by Kile Schwaneke on 9/19/2011
// Copyright 2011 BodSix, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPSprite.h"
@class SPStage;
@class SPQuad;

@interface SHClippedSprite : SPSprite {
@private
  SPQuad *mClip;
  SPStage *mStage;
  BOOL mClipping;

  // Scrolling
  BOOL mIsScrolling;
  float lastTouchX;
}

@property (nonatomic, readonly) SPQuad *clip;
@property (nonatomic, assign) BOOL clipping;

+ (SHClippedSprite *)clippedSprite;


@end