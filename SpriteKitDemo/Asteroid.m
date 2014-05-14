//
//  Asteroid.m
//  SpriteKitDemo
//
//  Created by Cody Mace on 5/6/14.
//  Copyright (c) 2014 Fossil Fueled. All rights reserved.
//

#import "Asteroid.h"

@implementation Asteroid

+ (Asteroid *)platformWithPosition:(NSInteger)x y:(NSInteger)y height:(double)height width:(double)width;
{
    Asteroid *asteroid = [[Asteroid alloc] initWithPosition:x y:y height:height width:width];
    return asteroid;
}

- (id)initWithPosition:(NSInteger)x y:(NSInteger)y height:(double)height width:(double)width;
{
    self = [super initWithTexture:[SKTexture textureWithImageNamed:@"asteroid-icon"]];
    if (self)
    {
        self.size = CGSizeMake(width, height);
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:width/2];
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.mass = 50;
        self.physicsBody.dynamic = NO;
        self.physicsBody.friction = .9;
    }
    return self;
}

- (void)move
{
    self.position = CGPointMake(self.position.x - 2, self.position.y);
}

@end
