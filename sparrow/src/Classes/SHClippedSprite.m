//
// SHClippedSprite.m
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


#import "SHClippedSprite.h"
#import "SPEvent.h"
#import "SPQuad.h"
#import "SPStage.h"
#import "SPDisplayObject.h"
#import <OpenGLES/ES1/gl.h>

@interface SHClippedSprite ()
- (void)onAddedToStage:(SPEvent *)event;
@end

@implementation SHClippedSprite

+ (SHClippedSprite *)clippedSprite {
  return [[[SHClippedSprite alloc] init] autorelease];
}

- (SHClippedSprite *)init {
  if ((self = [super init])) {
    mClip = [[SPQuad alloc] init];
    mClip.visible = NO;
    mClip.width = 0;
    mClip.height = 0;
    [self addChild:mClip];
    mClipping = NO;
    [self addEventListener:@selector(onAddedToStage:) atObject:self forType:SP_EVENT_TYPE_ADDED_TO_STAGE];
  }
  return self;
}

- (void)dealloc {
  [self removeEventListener:@selector(onAddedToStage:) atObject:self forType:SP_EVENT_TYPE_ADDED_TO_STAGE];
  [mClip release];
  [super dealloc];
}

@synthesize clip = mClip;
@synthesize clipping = mClipping;

- (void)setWidth:(float)width {
  mClip.width = width;
  [super setWidth:width];
}

- (void)setHeight:(float)height {
  mClip.height = height;
  [super setHeight:height];
}

- (void)removeAllChildren
{
  [mClip retain];
  [super removeAllChildren];
  [self addChild:mClip];
  [mClip release];
}

- (void)onAddedToStage:(SPEvent *)event {
  [self removeEventListener:@selector(onAddedToStage:) atObject:self forType:SP_EVENT_TYPE_ADDED_TO_STAGE];
  mStage = (SPStage *)self.stage;
}

- (void)render:(SPRenderSupport *)support {
  if (mClipping) {
    glEnable(GL_SCISSOR_TEST);
    SPRectangle *clip = [mClip boundsInSpace:mStage];
    glScissor((clip.x*[SPStage contentScaleFactor]), (mStage.height*[SPStage contentScaleFactor])-(clip.y*[SPStage contentScaleFactor])-(clip.height*[SPStage contentScaleFactor]), (clip.width*[SPStage contentScaleFactor]), (clip.height*[SPStage contentScaleFactor]));
    [super render:support];
    glDisable(GL_SCISSOR_TEST);
  } else {
    [super render:support];
  }
}

- (SPRectangle *)boundsInSpace:(SPDisplayObject *)targetCoordinateSpace {
  if (mClipping) {
    return [mClip boundsInSpace:targetCoordinateSpace];
  } else {
    return [super boundsInSpace:targetCoordinateSpace];
  }
}
@end

@implementation SPDisplayObject (ClippedHitTest)
- (SPDisplayObject*)hitTestPoint:(SPPoint*)localPoint forTouch:(BOOL)isTouch
{
  if (isTouch && (!mVisible || !mTouchable)) return nil;
  
  SPDisplayObject *parent = self.parent;
  while (parent) {
    if ([parent isKindOfClass:[SHClippedSprite class]]) {
      SPMatrix *transformationMatrix = [self transformationMatrixToSpace:parent];
      SPPoint *transformedPoint = [transformationMatrix transformPoint:localPoint];
      if (![[parent boundsInSpace:parent] containsPoint:transformedPoint])
        return nil;
    }
    
    parent = parent.parent;
  }
  
  if ([[self boundsInSpace:self] containsPoint:localPoint]) return self;
  else return nil;
}
@end