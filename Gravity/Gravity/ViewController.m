//
//  ViewController.m
//  Gravity
//
//  Created by David Brown on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <stdlib.h>
#import "ViewController.h"

@interface ViewController ()

@property (strong) NSMutableArray* planets;
@property (strong) UIView* player;
@property (strong) NSTimer* mainClock;
@property (assign) CGPoint playerVector;
@property (assign) CGPoint orbitPoint;
@property (strong) NSMutableArray* orbitPoints;

- (void)mainClockTick:(NSTimer*)timer;

@end

@implementation ViewController

@synthesize planets = _planets;
@synthesize player = _player;
@synthesize mainClock = _mainClock;
@synthesize playerVector = _playerVector;
@synthesize orbitPoint = _orbitPoint;
@synthesize orbitPoints = _orbitPoints;

- (CGFloat)randomInRangeOf:(NSInteger)range {
    NSInteger amplification = 5000;
    NSInteger modulus = range * 2 * amplification;
    NSInteger preprocessed = arc4random() % modulus;
    NSInteger centeringFactor = range * amplification;
    preprocessed -= centeringFactor;
    CGFloat result = (preprocessed * 1.0) / (amplification * 1.0);
    return result;
}

- (void)resetPlayer {
    int maxDelta = 3;

    CGSize viewExtents = self.view.frame.size;
    
    self.player.center = CGPointMake(arc4random() % (int)viewExtents.height, arc4random() % (int)viewExtents.width);
    self.playerVector = CGPointMake([self randomInRangeOf:maxDelta], 
                                    [self randomInRangeOf:maxDelta]);
    NSLog(@"playerVector: %f %f", self.playerVector.x, self.playerVector.y);
}

- (void)placeGravitySource:(CGPoint)sourcePoint {
    NSValue* v = [NSValue valueWithBytes:&sourcePoint objCType:@encode(CGPoint)];
    [self.orbitPoints addObject:v];
    
    UIView* sun = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
    sun.backgroundColor = [UIColor yellowColor];
    sun.layer.cornerRadius = 50.0;
    sun.center = sourcePoint;
    [self.view addSubview:sun];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor blackColor];
    self.orbitPoints = [NSMutableArray new];
    
    CGSize viewExtents = self.view.frame.size;
    
    [self placeGravitySource:CGPointMake(viewExtents.height / 3.0, viewExtents.width / 3.0)];
    [self placeGravitySource:CGPointMake(viewExtents.height / 3.0, (viewExtents.width / 3.0) * 2.0)];
    [self placeGravitySource:CGPointMake((viewExtents.height / 3.0) * 2.0, viewExtents.width / 3.0)];
    [self placeGravitySource:CGPointMake((viewExtents.height / 3.0) * 2.0, (viewExtents.width / 3.0) * 2.0)];
    
    self.player = [[UIView alloc] initWithFrame:CGRectMake(viewExtents.height / 2.0, viewExtents.width / 4.0, 20.0, 20.0)];
    self.player.backgroundColor = [UIColor greenColor];
    self.player.layer.cornerRadius = 10.0;
    [self.view addSubview:self.player];
    
    [self resetPlayer];
    
    self.mainClock = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                      target:self 
                                                    selector:@selector(mainClockTick:) 
                                                    userInfo:nil 
                                                     repeats:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
}

- (void)mainClockTick:(NSTimer *)timer {
    CGFloat decay = 0.9995;
    CGPoint center = self.player.center;
    CGPoint pVector = self.playerVector;
    pVector.x *= decay;
    pVector.y *= decay;

    CGFloat gravity = 7.0;
    CGFloat xv = 0.0;
    CGFloat yv = 0.0;
    
    for (NSValue* v in self.orbitPoints) {
        CGPoint gravityCenter;
        [v getValue:&gravityCenter];
        
        CGFloat diffx = gravityCenter.x - center.x;
        CGFloat diffy = gravityCenter.y - center.y;
        
        CGFloat distance = sqrt(diffx * diffx + diffy * diffy);
        
        xv += diffx * gravity / (distance * distance);
        yv += diffy * gravity / (distance * distance);
    }
    
    pVector.x += xv;
    pVector.y += yv;

    self.playerVector = pVector;
    
    center.x += self.playerVector.x;
    center.y += self.playerVector.y;
    self.player.center = center;
    
    CGSize viewExtents = self.view.frame.size;
    
    if (center.x < -50.0 || center.y < -50.0 || center.y > viewExtents.width + 50.0 || center.x > viewExtents.height + 50.0) {
        [self resetPlayer];
    }
}

@end
