//
//  Asteroid.h
//  SpriteKitDemo
//
//  Created by Cody Mace on 5/6/14.
//  Copyright (c) 2014 Fossil Fueled. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Asteroid : SKSpriteNode

+ (Asteroid *)platformWithPosition:(NSInteger)x y:(NSInteger)y height:(double)height width:(double)width;

- (id)initWithPosition:(NSInteger)x y:(NSInteger)y height:(double)height width:(double)width;

- (void)move;

@end
