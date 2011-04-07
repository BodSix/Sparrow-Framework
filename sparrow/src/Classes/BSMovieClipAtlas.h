//
//  BSMoveClipAtlas.h
//  Sparrow Extension
//
//  Created by Cory Osborn on 4/5/11.
//  Copyright 2011 BodSix, Inc. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.

#import "BSMovieClipAtlas.h"
#import "Sparrow.h"


/** ------------------------------------------------------------------------------------------------
 
 An animation atlas is a collection of named movie clips that are pulled from multiple textures and 
 texture atlases.  
 
 Whatever tool you use, Sparrow expects the following file format:
 
  <MovieClipAtlas>
    <Textures>
      <Texture name='texture1' imagePath='path/to/image.png'/>
      <TextureAtlas name='atlas1' atlasPath='path/to/atlas.xml'/>
    </Textures>
    <Sounds>
      <Sound name='sound1' soundPath='path/to/sound.caf'/>
    </Sounds>
    <MovieClip name='clip1' fps='8' loop='true'>
      <Frame texture='texture1' duration='1'/>
      <Frame texture='atlas1.nw1'/>
      <Frame texture='atlas1.nw2'/>
    </MovieClip>
    <MovieClip name='clip2' fps='8' loop='true'>
      <Frame texture='atlas1.sw1' sound='sound1'/>
      <Frame texture='atlas1.sw2'/>
    </MovieClip>
  </MovieClipAtlas>
 
 ------------------------------------------------------------------------------------------------- */
#import <Foundation/Foundation.h>
#import "SPTexture.h"
#import "SPTextureAtlas.h"
#import "SPSound.h"
#import "SPSoundChannel.h"
#import "SPMovieClip.h"

@interface BSFrameDef : NSObject {
  @protected
  NSString *textureName;
  NSString *duration;
  NSString *soundName;
}
-(id)initWithTextureName:(NSString *)pTextureName duration:(NSString *)pDuration soundName:(NSString *)pSoundName;
+(id)frameWithTextureName:(NSString *)pTextureName duration:(NSString *)pDuration soundName:(NSString *)pSoundName;

@property (nonatomic, copy) NSString *textureName;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *soundName;

@end



@interface BSMovieClipDef : NSObject {
  @protected
  NSString *name;
  float fps;
  BOOL loop;
  NSMutableArray *frames;
}

-(id)initWithName:(NSString *)pName fps:(float)pfps loop:(BOOL)pLoop;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) float fps;
@property (nonatomic, assign) BOOL loop;
@property (nonatomic, readonly) NSMutableArray *frames;

-(void)addFrame:(BSFrameDef *)frame;
-(void)addFrame:(NSString *)pTextureName duration:(NSString *)pDuration soundName:(NSString *)pSoundName;

@end




#ifdef __IPHONE_4_0
@interface BSMovieClipAtlas : NSObject  <NSXMLParserDelegate> 
#else
@interface BSMovieClipAtlas : NSObject 
#endif
{
  @private
  NSMutableDictionary *textures;
  NSMutableDictionary *sounds;
  NSMutableDictionary *movieClipDefs;

  // only used during xml parsing
  BSMovieClipDef *parserClipDef;
  SPMovieClip *parserClip;
  BOOL parserClipLoop;
  float parserClipFPS;
  NSString *parserClipName;
}

/// Initializer
-(id)init;
/// Initializes the MovieClipAtlas from an XML file.
-(id)initWithContentsOfFile:(NSString *)path;
/// Factory method
+(BSMovieClipAtlas *)atlasWithContentsOfFile:(NSString *)path;

@property (nonatomic, readonly) NSDictionary *textures;
@property (nonatomic, readonly) NSDictionary *sounds;
@property (nonatomic, readonly) NSDictionary *movieClipDefs;

-(void)addTexture:(SPTexture *)texture withName:(NSString *)name;
-(void)addTexturePath:(NSString *)texturePath withName:(NSString *)name;
-(void)addTextureAtlas:(SPTextureAtlas *)textureAtlas withName:(NSString *)name;
-(void)addTextureAtlasPath:(NSString *)textureAtlasPath withName:(NSString *)name;
-(void)addSound:(SPSound *)sound withName:(NSString *)name;
-(void)addSoundPath:(NSString *)soundPath withName:(NSString *)name;

-(SPTexture *)findTexture:(NSString *)textureName;
-(SPSoundChannel *)getSoundChannel:(NSString *)soundName;
-(SPMovieClip *)getMovieClip:(NSString *)clipName;

@end
