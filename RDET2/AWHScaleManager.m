//
//  AWHScaleManager.m
//  RockyDontEatThat
//
//  Created by Pete Johnson on 7/19/12.
//  Copyright (c) 2012 Apps With Heart. All rights reserved.
//

#import "AWHScaleManager.h"
#import "AWHGameStateManager.h"

@implementation AWHScaleManager

// Singleton accessor method
+ (id)sharedScaleManager {
    static id sharedScaleManager = nil;
    
    if (sharedScaleManager == nil) {
        sharedScaleManager = [[self alloc] init];
    }
    
    return sharedScaleManager;
}

// One-time logic for computing specifics of the current device
-(id) init
{
	if( (self=[super init]) ) {
        // Logic adapted from
        // http://craigmcfarlaneoz.wordpress.com/2012/03/09/cocos2d-detecting-iphone-iphone-hd-ipad-and-ipad-hd/
        
        //Grab the screens scale factor – 1.0 = SD screen & 2.0 = HD screen
        CGFloat deviceScale = [[UIScreen mainScreen] scale];
        
        // Set our internal scale variable relative to a retina display
        if (deviceScale > 1.0) {
            retina = YES;
            NSLog(@"retina: YES");
        } else {
            retina = NO;
            NSLog(@"retina: NO");
        }
        
        // Get dimensions accounting for autorotation
        CGSize size = [[CCDirector sharedDirector] winSize];
        screenWidth = size.width;
        screenHeight = size.height;
        
        //and now we grab the device model and compute padding widths assuming aspect ratios stay constant
        NSString* valueDevice = [[UIDevice currentDevice] model];
        if ([valueDevice rangeOfString:@"iPad"].location == NSNotFound)  
        //Test to see if our valueDevice NSString does not contains the substring iPad & if it does not it is an iPhone otherwise it is an iPad             
        {
            iPad = NO;
            NSLog(@"iPad: NO");
            paddingWidth = (screenWidth-480)/2;
            paddingHeight = (screenHeight-320)/2;
        } else {
            iPad = YES;
            NSLog(@"iPad: YES");
            paddingWidth = (screenWidth - 960) / 2;
            paddingHeight = (screenHeight - 640) / 2;
        }
        
        NSLog( @"Width: %f", screenWidth);
        NSLog( @"Padding Width: %f", paddingWidth);
        NSLog( @"Height: %f", screenHeight);
        NSLog( @"Padding Height: %f", paddingHeight);
	}
	return self;
}

// Take in an X, Y in Cocos2d coordinates and, if on an iPad, convert them to their equivalents
// in the centered letterbox
-(CGPoint)scalePointX:(float)x andY:(float)y {
    if (!iPad)
        // Regardless of actual height/width iPhone base coords in Cocos2d is 480x320
        return ccp(x+paddingWidth,y + paddingHeight);
    else {
        // Regardless of actual height/width iPad base coords in Cocos2d is 960x640
        return ccp(2*x+paddingWidth, 2*y+paddingHeight);
    }
}

// Enforces font size scaling for iPad vs iPhone
-(float)scaleFontSize:(float)size {
    if (!iPad)
        return size;
    else 
        return 2*size;    
}

// Enforces image scaling for iPad vs iPhone
-(float)scaleImage {
    float retval = 1.0;
    if (!iPad)
        retval =  0.50;
    
    //NSLog(@"scaleImage: %f", retval);
    return retval;
    
}

// Enforces house ad scaling for iPad vs iPhone
-(float)scaleAd {
    float retval = 2.0;
    if (!iPad)
        retval =  1.0;
    
    //NSLog(@"scaleAd: %f", retval);
    return retval;
    
}

// Builds a correctly scaled frame for ads
// Note: this is in UIKit pixels, not Cocos2d points
-(CGRect)scaledAdFrame {
    if(iPad)
        return CGRectMake(0,0,640,100);
    else 
        return CGRectMake(0,0,320,50);
}

// Builds a correctly scaled size for ads
// Note: this is in UIKit pixels, not Cocos2d points
-(CGSize)scaledAdSize {
    if(iPad)
        return CGSizeMake(640,100);
    else 
        return CGSizeMake(320,50);
}

// Properly scales the Y of an ad for iPad vs iPhone 
// Note: this is in UIKit pixels, not Cocos2d points
-(float)scaleAdOriginY {
    if(iPad)
        return 70;
    else 
        return 0;
}

// Properly scales the padding of an ad for iPad vs iPhone 
// Note: this is in UIKit pixels, not Cocos2d points
-(float)scaleAdPadding {
    if(iPad)
        return 10;
    else 
        return 5;
}

// Converts a text dimension specifier to a float value
-(float)convertDimension:(NSString*)dim ofSprite:(CCSprite*)sprite{
    float retval = 0.0;
    AWHGameStateManager *gameStateManager = [AWHGameStateManager sharedGameStateManager];
    if ([dim isEqualToString:@"E"]) {
        if (!iPad)
             retval = 480 + paddingWidth;
        else {
            retval = 480 + paddingWidth/2;
        }
    } else if ([dim isEqualToString:@"E+"]) {
        if (!iPad)
            retval = 480 + paddingWidth + [sprite boundingBox].size.width/2;
        else {
            retval = 480 + paddingWidth/2 + [sprite boundingBox].size.width/4;      
        }
    } else if ([dim isEqualToString:@"W"]) {
        if (!iPad)
            retval = -1 * paddingWidth;
        else {
            retval = -1 * paddingWidth/2;
        }
    } else if ([dim isEqualToString:@"W-"]) {
        if (!iPad)
            retval = -1 * paddingWidth - [sprite boundingBox].size.width/2;
        else {
            retval = -1 * paddingWidth/2 - [sprite boundingBox].size.width/2;
        }
    } else if ([dim isEqualToString:@"RandomY"]) {
        int w=[sprite textureRect].size.width/2;
        int h=[sprite textureRect].size.height/2;
        int off=h;
        if (w > h)
            off = w;
        retval = (arc4random() % (300-off)) + 50;
    } else if ([dim isEqualToString:@"Middle"]) {
        retval = 160;
    } else if ([dim isEqualToString:@"RemoteX"]) {
        retval = gameStateManager.removeX;
    }else if ([dim isEqualToString:@"RemoteY"]) {
        retval = gameStateManager.removeY;
    }else if ([dim isEqualToString:@"StraightY"]) {
        retval = sprite.position.y;
        if(iPad) {
            retval = sprite.position.y/2 - 32;
        }
    } else if ([dim isEqualToString:@"EScroll"]) {
        // First, compute the right side of the leftmost tile
        int numTiles = [self computeNumHorizTiles:[sprite boundingBox].size.width];
        int rsideLeftMostTile;
        if(!iPad)
        {
            rsideLeftMostTile = [self pointsFromRightBoundary:[sprite boundingBox].size.width n:numTiles-1] + [sprite boundingBox].size.width/2;
            retval = [self pointsFromRightBoundary:[sprite boundingBox].size.width n:-1] - rsideLeftMostTile + [sprite boundingBox].size.width - paddingWidth;
        }
        else {
            rsideLeftMostTile = [self pointsFromRightBoundary:[sprite boundingBox].size.width n:numTiles-1] + [sprite boundingBox].size.width/2;
            retval = [self pointsFromRightBoundary:[sprite boundingBox].size.width n:-1] - rsideLeftMostTile + [sprite boundingBox].size.width/2 - paddingWidth/2 -1;
        }
        NSLog(@"E-Scroll %f", retval);
    } else {
        // Assume it's a number
        retval = [dim floatValue];
    }
    return retval;
}

// Allows plist for sprite MoveTos to be in terms of speed instead of duration
-(float)computeDurationFromSpeed:(NSString*)speed fromX:(float)fx fromY:(float)fy toX:(float)tx toY:(float)ty{
    float retval = 0.0;
    
    if (![speed isEqualToString:@"0"]) {
        float speedFloat = [speed floatValue];
        
        // Compute Distance
        CGPoint finish;
        CGPoint start;
        start = ccp(fx,fy);
        finish = [self scalePointX:tx andY:ty];

        float distance = ccpDistance(start, finish); 
        //NSLog(@"Speed: %f Distance: %f Duration: %f", speedFloat, distance, distance/speedFloat);
        //NSLog(@"Start x:%f y:%f  Finish x:%f y:%f", start.x, start.y, finish.x, finish.y);
        retval = distance/speedFloat;
        if(iPad) 
            retval = retval/2;
        
    }
    
    return retval;
}

-(int)computeNumHorizTiles:(float)width {
    int retval = 0;
    retval = screenWidth/width;
    NSLog(@"Sprite Width: %f Win width: %f Retval: %d", width, screenWidth, retval+1);
    return retval+1;
}

-(float)pointsFromRightBoundary:(float)width n:(int)n {
    float retval = screenWidth - width/2-n*width+n+1;
    if(iPad)
        retval = screenWidth/2 - width/4-n*width/2+n+1;
    return retval;
}

@end
