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

#import "SPDisplayObject.h"
#import "SPEvent.h"
#import "SPQuad.h"
#import "SPStage.h"
#import "SPTouchEvent.h"
#import "SPTween.h"
#import <OpenGLES/ES1/gl.h>

static const float BOUNCE_DURATION   = 0.4f;

@interface SHClippedSprite ()

- (void)onAddedToStage:(SPEvent *)event;
- (void)onClippedSpriteTouch:(SPTouchEvent*)touchEvent;
- (void)bounceMenuItems;

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
    [super addChild:mClip]; // Avoid our own addChild as it increments by 1 to avoid the mClip
    mClipping = NO;
    mCanScrollX = NO;
    mCanScrollY = NO;
    mIsScrolling = NO;
    [self addEventListener:@selector(onAddedToStage:) atObject:self forType:SP_EVENT_TYPE_ADDED_TO_STAGE];
    [self addEventListener:@selector(onClippedSpriteTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
  }
  return self;
}

- (void)dealloc {
  [self removeEventListener:@selector(onAddedToStage:) atObject:self forType:SP_EVENT_TYPE_ADDED_TO_STAGE];
  [self removeEventListener:@selector(onClippedSpriteTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];

  [mClip release];
  [super dealloc];
}

@synthesize clip = mClip;
@synthesize clipping = mClipping;
@synthesize canScrollX = mCanScrollX;
@synthesize canScrollY = mCanScrollY;
@synthesize isScrolling = mIsScrolling;

@synthesize scrollXPos;
@synthesize scrollYPos;

- (float)scrollXPos {
  if ([self numChildren] == 1)  // mClip only
    return 0.0f;

  return [self childAtIndex:[self childIndex:mClip] + 1].x;  // Skip the mClip
}

- (void)setScrollXPos:(float)pScrollXPos {
  for (SPDisplayObject *spdo in self) {
    if (mCanScrollX)
      spdo.x += pScrollXPos;
  }
}

- (float)scrollYPos {
  if ([self numChildren] == 1)  // mClip only
    return 0.0f;

  return [self childAtIndex:[self childIndex:mClip] + 1].y;  // Skip the mClip
}

- (void)setScrollYPos:(float)pScrollYPos {
  for (SPDisplayObject *spdo in self) {
    if (mCanScrollX)
      spdo.y += pScrollYPos;
  }
}

#pragma mark - overridding base class methods so that callers don't need to care
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

#pragma mark -
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

#pragma mark - NSFastEnumeration
-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
  [mClip retain];
  [mClip removeFromParent];

  NSUInteger retVal = [super countByEnumeratingWithState:state objects:stackbuf count:len];

  [self addChild:mClip atIndex:0];
  [mClip release];

  return retVal;
}

#pragma mark - Scrolling
- (void)onClippedSpriteTouch:(SPTouchEvent*)touchEvent {
  if (!mCanScrollX && !mCanScrollY)
    return;

  SPTouch *touch = [[[touchEvent touchesWithTarget:self] allObjects] objectAtIndex:0];
  SPPoint *touchPos = [touch locationInSpace:self];

  if (touch.phase == SPTouchPhaseMoved) {
    mIsScrolling = YES;

    for (SPDisplayObject *spdo in self) {
      if (mCanScrollX)
        spdo.x += touchPos.x - lastTouchX;

      if (mCanScrollY)
      spdo.y += touchPos.y - lastTouchY;
    }
  } else if (touch.phase == SPTouchPhaseEnded) {
    mIsScrolling = NO;
    [self bounceMenuItems];
  }

  if (mCanScrollX)
    lastTouchX = touchPos.x;
  if (mCanScrollY)
    lastTouchY = touchPos.y;
}

- (void)bounceMenuItems {
  NSAssert(mCanScrollX || mCanScrollY, @"SHClippedSprite: bounceMenuItems: Cannot scroll!");

  if (1 == self.numChildren)
    return;

  // min could be negative and max could be out of view.  This is a feature.
  SPDisplayObject *firstChild = [self childAtIndex:[self childIndex:mClip] + 1];  // Skip the mClip
  SPDisplayObject *lastchild  = [self childAtIndex:self.numChildren - 1];
  float maxX = lastchild.x + lastchild.width;
  float maxY = lastchild.y + lastchild.height;
  float minX = firstChild.x;
  float minY = firstChild.y;

  float bounceDistanceX;
  float bounceDistanceY;
  for (SPDisplayObject *spdo in self) { // fast enumeration skips mClip
    bounceDistanceX = 0.0f;
    bounceDistanceY = 0.0f;

    if (mCanScrollX) {
      if (minX > 0.0f || (maxX - minX) < self.width)
        bounceDistanceX = 0.0f - minX;
      else if (maxX < self.width)
        bounceDistanceX = self.width - maxX;
    }

    if (mCanScrollY) {
      if (minY > 0.0f || (maxY - minY) < self.height)
        bounceDistanceY = 0.0f - minY;
      else if (maxY < self.height)
        bounceDistanceY = self.height - maxY;
    }

    if (0.0f == bounceDistanceX && 0.0f == bounceDistanceY)
      continue;

    SPTween *bounceMenuItems = [SPTween tweenWithTarget:spdo time:BOUNCE_DURATION transition:SP_TRANSITION_EASE_OUT];
    if (0.0f != bounceDistanceX)
      [bounceMenuItems animateProperty:@"x" targetValue:spdo.x + bounceDistanceX];
    if (0.0f != bounceDistanceY)
      [bounceMenuItems animateProperty:@"y" targetValue:spdo.y + bounceDistanceY];
    [self.stage.juggler addObject:bounceMenuItems];
  }
}

@end

#pragma mark - SPDisplayObject (ClippedHitTest)
@implementation SPDisplayObject (ClippedHitTest)
- (SPDisplayObject*)hitTestPoint:(SPPoint*)localPoint forTouch:(BOOL)isTouch {
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

