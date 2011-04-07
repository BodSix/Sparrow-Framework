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
      <Frame texture='atlas1.nw*'/>
    </MovieClip>
    <MovieClip name='clip2' fps='8' loop='true'>
      <Frame texture='atlas1.sw1' sound='sound1'/>
      <Frame texture='atlas1.sw2'/>
    </MovieClip>
  </MovieClipAtlas>
 
 ------------------------------------------------------------------------------------------------- */
#import <Foundation/Foundation.h>


@interface BSMovieClipAtlas : NSObject {
    
}

@end
