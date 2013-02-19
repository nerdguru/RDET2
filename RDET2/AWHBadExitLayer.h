//
//  AWHBadExitLayer.h
//  RockyDontEatThat
//
//  Created by Pete Johnson on 9/8/12.
//  Copyright 2012 AppsWithHeart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AWHBaseLayer.h"

@interface AWHBadExitLayer : AWHBaseLayer {
    CCLabelTTF *remainingCalls;
    NSString* badEffect;
    NSString* foodEffect;
}
-(id)initWithDict:(NSDictionary *)dict withFileName:(NSString*)fileName;
@end
