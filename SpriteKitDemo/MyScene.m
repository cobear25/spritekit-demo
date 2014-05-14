//
//  MyScene.m
//  SpriteKitDemo
//
//  Created by Cody Mace on 4/29/14.
//  Copyright (c) 2014 Fossil Fueled. All rights reserved.
//

#import "MyScene.h"
#import "Asteroid.h"

@interface MyScene()<SKPhysicsContactDelegate>
@property (strong, nonatomic) SKSpriteNode *ship;
@property (strong, nonatomic) SKEmitterNode *fire;
@property (nonatomic, assign) NSTimeInterval previousUpdateTime;
@property (nonatomic, assign) NSTimeInterval newAsteroidTimeInterval;
@property (strong, nonatomic) Asteroid *asteroid;
@property (strong, nonatomic) NSMutableArray *asteroidArray;
@property (strong, nonatomic) SKLabelNode *healthLabel;
@property (strong, nonatomic) SKLabelNode *gameOverLabel;
@property (assign, nonatomic) NSInteger shipHealth;
@property (strong, nonatomic) SKSpriteNode *restartButton;
@end

@implementation MyScene

const uint32_t edgeCategory = 0x1 << 1;
const uint32_t shipCategory = 0x1 << 2;
const uint32_t asteroidCategory = 0x1 << 3;

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithWhite:0.0 alpha:1];
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, self.size.width, self.size.height + 100)];
        self.physicsWorld.gravity = CGVectorMake(0, -8);
        self.physicsWorld.contactDelegate = self;

        self.healthLabel = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
        self.healthLabel.fontSize = 18;
        self.healthLabel.position = CGPointMake(100, self.size.height-50);
        self.shipHealth = 10;
        self.healthLabel.text = [NSString stringWithFormat:@"Health: %lu", (long)self.shipHealth];
        self.healthLabel.zPosition = 50;
        [self addChild:self.healthLabel];

//        [self.gameOverLabel setHidden:YES];

        self.ship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];

        self.ship.position = CGPointMake(CGRectGetMidX(self.frame)-100, CGRectGetMidY(self.frame)+150);
        self.ship.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.ship.frame.size];
        [self.ship.physicsBody setLinearDamping:3];
        self.ship.physicsBody.categoryBitMask = shipCategory;
        self.ship.physicsBody.contactTestBitMask = asteroidCategory;
        self.ship.zPosition = 20;

        NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"EngineFire" ofType:@"sks"];
        self.fire = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
        [self addChild:self.fire];

        [self.ship setScale:0.2];
        [self addChild:self.ship];

        self.asteroidArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addAsteroid
{
    Asteroid *asteroid = [[Asteroid alloc] initWithPosition:600 y:500 height:110 width:110];
    [self addChild:asteroid];
    Asteroid *asteroid2 = [[Asteroid alloc] initWithPosition:600 y:500 height:110 width:110];
    [self addChild:asteroid2];
    CGFloat randY = arc4random_uniform(11)+6;
    CGFloat randY2 = arc4random_uniform(6);
    asteroid.position = CGPointMake(400, randY*50);
    asteroid2.position = CGPointMake(400, randY2*50);
    [self.asteroidArray addObject:asteroid];
    [self.asteroidArray addObject:asteroid2];

}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    UITouch *touch = touches.anyObject;
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    if ([node.name isEqualToString:@"restart"])
    {
        [self restart];
    }
    else
    {
        [self.ship.physicsBody applyImpulse:CGVectorMake(0, 3000)];
    }

}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    self.fire.particlePosition = CGPointMake(self.ship.position.x, self.ship.position.y - self.ship.size.height/2);
    self.ship.zRotation = 0;

    CFTimeInterval timeSinceLast = currentTime - self.previousUpdateTime;
    self.previousUpdateTime = currentTime;

    if (timeSinceLast > .02)
    {
        timeSinceLast = .02;
    }

    self.newAsteroidTimeInterval += timeSinceLast;
    if (self.newAsteroidTimeInterval > 2)
    {
        self.newAsteroidTimeInterval = 0;
        [self addAsteroid];
    }

    [self.asteroidArray enumerateObjectsUsingBlock:^(Asteroid *currentAsteroid, NSUInteger idx, BOOL *stop) {
        currentAsteroid.physicsBody.categoryBitMask = asteroidCategory;
        currentAsteroid.physicsBody.contactTestBitMask = shipCategory;
        [currentAsteroid move];
        if (currentAsteroid.position.x < 0-currentAsteroid.size.width)
        {
            [self.asteroidArray removeObject:currentAsteroid];
        }
    }];
    self.healthLabel.text = [NSString stringWithFormat:@"Health: %ld", (long)self.shipHealth];
    if (self.shipHealth == 0)
    {
        [self gameOver];
        self.paused = YES;
        self.scene.view.paused = YES;
    }
    NSLog(@"%d", self.asteroidArray.count);
}

- (void)gameOver
{
    [self setPaused:YES];

    self.gameOverLabel = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    self.gameOverLabel.fontSize = 30;
    self.gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.gameOverLabel.text = @"GAME OVER";
    self.gameOverLabel.zPosition = 50;
//    [self.gameOverLabel setHidden:NO];
    [self addChild:self.gameOverLabel];

    self.restartButton = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(200, 80)];
    self.restartButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-100);
    SKLabelNode *restartLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    restartLabel.position = CGPointMake(self.restartButton.anchorPoint.x, self.restartButton.anchorPoint.y - 12);
    [restartLabel setText:@"Restart"];
    [self.restartButton addChild:restartLabel];
    [self.restartButton setName:@"restart"];
    [self addChild:self.restartButton];
}

- (void)restart
{
    NSLog(@"restart");
    [self.gameOverLabel removeFromParent];
    [self.restartButton removeFromParent];
    self.shipHealth = 10;
    self.ship.position = CGPointMake(CGRectGetMidX(self.frame)-100, CGRectGetMidY(self.frame)+150);
    for (Asteroid *asteroid in self.asteroidArray)
    {
        asteroid.hidden = YES;
        [asteroid removeFromParent];
    }
    [self setPaused:NO];
    [self.scene.view setPaused:NO];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;

    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    if ((firstBody.categoryBitMask & shipCategory) != 0 && (secondBody.categoryBitMask & asteroidCategory) != 0)
    {
        self.shipHealth -= 1;
    }
}

@end
