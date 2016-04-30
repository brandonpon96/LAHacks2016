//
//  FaceDetectManager.h
//  LAHacks2016
//
//  Created by Shannon Phu on 4/30/16.
//  Copyright © 2016 Brandon Pon. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;

@interface FaceDetectManager : NSObject
+ (void)getFaceAttributesWithImage:(UIImage *)image;
+ (void)getSimilarityBetweenFace1:(NSString *)faceID1 andFace2:(NSString *)faceID;
@end
