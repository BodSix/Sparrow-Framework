//
//  BSMovieClipAtlas.m
//  Sparrow Extension
//
//  Created by Cory Osborn on 4/5/11.
//  Copyright 2011 BodSix, Inc. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.

#import "BSMovieClipAtlas.h"


@implementation BSFrameDef 

-(id)initWithTextureName:(NSString *)pTextureName duration:(NSString *)pDuration soundName:(NSString *)pSoundName {
  if ((self = [super init])) {
    self.textureName = pTextureName;
    self.duration = pDuration;
    self.soundName = pSoundName;
  }
  return self;
}

+(id)frameWithTextureName:(NSString *)pTextureName duration:(NSString *)pDuration soundName:(NSString *)pSoundName {
  return [[[BSFrameDef alloc] initWithTextureName:pTextureName duration:pDuration soundName:pSoundName] autorelease];
}

-(void)dealloc {
  [textureName release];
  [super dealloc];
}

@synthesize textureName;
@synthesize duration;
@synthesize soundName;

@end



@implementation BSMovieClipDef 

-(id)initWithName:(NSString *)pName fps:(float)pfps loop:(BOOL)pLoop {
  if ((self = [super init])) {
    self.name = pName;
    self.fps = pfps;
    self.loop = pLoop;
    frames = [[NSMutableArray alloc] initWithCapacity:8];
  }
  return self;
}

-(void)dealloc {
  [frames release];
  [name release];
  [super dealloc];
}

@synthesize name;
@synthesize fps;
@synthesize loop;
@synthesize frames;

-(void)addFrame:(BSFrameDef *)frame {
  [frames addObject:frame];
}
-(void)addFrame:(NSString *)pTextureName duration:(NSString *)pDuration soundName:(NSString *)pSoundName {
  [frames addObject:[BSFrameDef frameWithTextureName:pTextureName duration:pDuration soundName:pSoundName]];
}

@end



// --- class implementation ------------------------------------------------------------------------
@implementation BSMovieClipAtlas

-(id)init {
  return [self initWithContentsOfFile:nil];
}

-(id)initWithContentsOfFile:(NSString *)path {
  if ((self = [super init])) {
    textures = [[NSMutableDictionary alloc] init];
    sounds = [[NSMutableDictionary alloc] init];
    movieClipDefs = [[NSMutableDictionary alloc] init];
    [self parseAtlasXml:path];
  }
  return self;
}

+(BSMovieClipAtlas *)mcAtlasWithContentsOfFile:(NSString *)path {
  return [[[BSMovieClipAtlas alloc] initWithContentsOfFile:path] autorelease];
}

-(void)dealloc {
  [movieClipDefs release];
  [sounds release];
  [textures release];
  [super dealloc];
}

@synthesize textures;
@synthesize sounds;
@synthesize movieClipDefs;


-(void)parseAtlasXml:(NSString *)path {
  if (!path) 
    return;

  SP_CREATE_POOL(pool);
  
  parserClipDef = nil;
  
  float scale = [SPStage contentScaleFactor];
  NSString *fullPath = [[NSBundle mainBundle] pathForResource:path withScaleFactor:scale];
  NSURL *xmlUrl = [NSURL fileURLWithPath:fullPath];
  NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlUrl];
  xmlParser.delegate = self;
  BOOL success = [xmlParser parse];
  
  SP_RELEASE_POOL(pool);
  
  if (!success)    
    [NSException raise:SP_EXC_FILE_INVALID 
                format:@"could not parse movie clip atlas %@. Error code: %d, domain: %@", 
                       path, xmlParser.parserError.code, xmlParser.parserError.domain];
  
  [xmlParser release];    
  [parserClipDef release];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
                                       namespaceURI:(NSString *)namespaceURI 
                                      qualifiedName:(NSString *)qName 
                                         attributes:(NSDictionary *)attributeDict {
  if ([elementName isEqualToString:@"Texture"]) {
    [self addTexturePath:[attributeDict valueForKey:@"imagePath"] withName:[attributeDict valueForKey:@"name"]];
  
  } else if ([elementName isEqualToString:@"TextureAtlas"]) {
    [self addTextureAtlasPath:[attributeDict valueForKey:@"atlasPath"] withName:[attributeDict valueForKey:@"name"]];
  
  } else if ([elementName isEqualToString:@"Sound"]) {
    [self addSoundPath:[attributeDict valueForKey:@"soundPath"] withName:[attributeDict valueForKey:@"name"]];
  
  } else if ([elementName isEqualToString:@"MovieClip"]) {
    [parserClipDef release];
    parserClipDef = [[BSMovieClipDef alloc] initWithName:[attributeDict valueForKey:@"name"] 
                                                     fps:[[attributeDict valueForKey:@"fps"] floatValue] 
                                                    loop:[[attributeDict valueForKey:@"loop"] boolValue]];
    [movieClipDefs setObject:parserClipDef forKey:parserClipDef.name];

  } else if ([elementName isEqualToString:@"Frame"]) {
    [parserClipDef addFrame:[attributeDict valueForKey:@"texture"] 
                   duration:[attributeDict valueForKey:@"duration"] 
                  soundName:[attributeDict valueForKey:@"sound"]];
  }
}


-(void)addTexture:(SPTexture *)texture withName:(NSString *)name {
  [textures setObject:texture forKey:name];
}

-(void)addTexturePath:(NSString *)texturePath withName:(NSString *)name {
  [textures setObject:[SPTexture textureWithContentsOfFile:texturePath] forKey:name];
}

-(void)addTextureAtlas:(SPTextureAtlas *)textureAtlas withName:(NSString *)name {
  [textures setObject:textureAtlas forKey:name];
}

-(void)addTextureAtlasPath:(NSString *)textureAtlasPath withName:(NSString *)name {
  [textures setObject:[SPTextureAtlas atlasWithContentsOfFile:textureAtlasPath] forKey:name];
}

-(void)addSound:(SPSound *)sound withName:(NSString *)name {
  [sounds setObject:sound forKey:name];
}

-(void)addSoundPath:(NSString *)soundPath withName:(NSString *)name {
  [sounds setObject:[SPSound soundWithContentsOfFile:soundPath] forKey:name];
}



-(SPTexture *)findTexture:(NSString *)textureName {
  SPTexture *result = nil;
  NSRange atlasPrefix = [textureName rangeOfString:@"."];
  if (atlasPrefix.location == NSNotFound) {
    result = [textures valueForKey:textureName];
  } else {
    SPTextureAtlas *atlas = [textures valueForKey:[textureName substringToIndex:atlasPrefix.location]];
    result = [atlas textureByName:[textureName substringFromIndex:(atlasPrefix.location + atlasPrefix.length)]];
  }
  return result;
}

-(SPSoundChannel *)getSoundChannel:(NSString *)soundName {
  SPSound *sound = [self.sounds objectForKey:soundName];
  return [sound createChannel];
}

-(SPMovieClip *)getMovieClip:(NSString *)clipName {
  SPMovieClip *result = nil;
  BSMovieClipDef *clip = [movieClipDefs objectForKey:clipName];
  if (clip && ((id)clip) != [NSNull null]) {
    for (BSFrameDef *frame in clip.frames) {
      SPTexture *texture = [self findTexture:frame.textureName];
      assert(texture != nil);
      /* debugging some cross-thread problems with SPRectangle
      if ([texture isKindOfClass:[SPSubTexture class]]) {
        SPSubTexture *subt = (SPSubTexture *)texture;
        assert(subt.clipping.x >= 0);
        assert(subt.clipping.y >= 0);
        assert(subt.clipping.width <= 1.0);
        assert(subt.clipping.height <= 1.0);
      }
       */
      if (!result) {
        result = [SPMovieClip movieWithFrame:texture fps:clip.fps];
        result.loop = clip.loop;
      } else {
        [result addFrame:texture];
      }
      if (frame.duration)
        [result setDuration:[frame.duration doubleValue] atIndex:(result.numFrames - 1)];
      if (frame.soundName)
        [result setSound:[self getSoundChannel:frame.soundName] atIndex:(result.numFrames - 1)];
    }
  }
  return result;
}
@end
