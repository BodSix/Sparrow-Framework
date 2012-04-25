//
//  SHPinchEvent.h
//  Sparrow
//
//  Created by Shilo White on 6/4/11.
//  Copyright 2011 Shilocity Productions. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#define SH_EVENT_TYPE_PINCH @"pinch"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SPEvent.h"
#import "SPStage.h"
@class SPPoint;
@class SPDisplayObject;

@interface SHPinchEvent : SPEvent {
	SPPoint *mLocation;
	float mScale;
    float mVelocity;
    uint mNumberOfTouches;
}

@property (nonatomic, readonly) SPPoint *location;
@property (nonatomic, readonly) float scale;
@property (nonatomic, readonly) float velocity;
@property (nonatomic, readonly) uint numberOfTouches;

- (id)initWithType:(NSString *)type location:(SPPoint *)location scale:(float)scale velocity:(float)velocity numberOfTouches:(uint)numberOfTouches;
- (id)initWithType:(NSString *)type location:(SPPoint *)location scale:(float)scale velocity:(float)velocity numberOfTouches:(uint)numberOfTouches bubbles:(BOOL)bubbles;
+ (SHPinchEvent *)eventWithType:(NSString *)type location:(SPPoint *)location scale:(float)scale velocity:(float)velocity numberOfTouches:(uint)numberOfTouches;
+ (SHPinchEvent *)eventWithType:(NSString *)type location:(SPPoint *)location scale:(float)scale velocity:(float)velocity numberOfTouches:(uint)numberOfTouches bubbles:(BOOL)bubbles;
- (SPPoint *)locationInSpace:(SPDisplayObject *)space;

@end

@interface SPStage (pinch)
- (void)startPinchRecognizer;
- (void)stopPinchRecognizer;
@end