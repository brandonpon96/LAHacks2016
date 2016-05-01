//
//  MarvelManager.h
//  LAHacks2016
//
//  Created by Brandon Pon on 4/30/16.
//  Copyright © 2016 Brandon Pon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarvelManager : NSObject


+(void) loadCharacters;
+(NSArray*) getMale;
+(NSArray*) getFemale;
+(NSArray*) getCharacters;

@end
