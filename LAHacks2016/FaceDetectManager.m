//
//  FaceDetectManager.m
//  LAHacks2016
//
//  Created by Shannon Phu on 4/30/16.
//  Copyright © 2016 Brandon Pon. All rights reserved.
//

#import "FaceDetectManager.h"
#import <AFNetworking.h>
#import <MPOFaceSDK.h>
#import "MarvelManager.h"

@implementation FaceDetectManager

+ (void)getFaceAttributesWithImage:(UIImage *)image {
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:@"a3c7751246144ca296f6ba9cb1dd87e0"];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    NSArray *attr = @[@(MPOFaceAttributeTypeAge), @(MPOFaceAttributeTypeFacialHair), @(MPOFaceAttributeTypeHeadPose), @(MPOFaceAttributeTypeSmile), @(MPOFaceAttributeTypeGender)];
    
    // Get faceID for Marvel char, then when ready get user face attributes and get similarity
    [client detectWithData:imageData returnFaceId:YES returnFaceLandmarks:NO returnFaceAttributes:attr completionBlock:^(NSArray<MPOFace *> *collection, NSError *error) {
        
        if (error) {
            NSLog(@"Error: %@", error);
        }
        else {
            NSString *userFace;
            NSString *userGender;
            for (MPOFace *face in collection) {
                userFace = [NSString stringWithString:face.faceId];
                NSLog(@"User: %@", face.faceId);
                userGender = [NSString stringWithString:face.attributes.gender];
                NSLog(@"User: %@", face.attributes.gender);
                NSLog(@"User: %@", face.attributes.age.stringValue);
            }
            __block NSDictionary *character = [MarvelManager getMale];
            __block NSString *marvelURL = [character valueForKey:@"imageURL"];
            if ([userGender isEqualToString:@"male"]) {
                
            }
            
            [client detectWithUrl:marvelURL returnFaceId:YES returnFaceLandmarks:NO returnFaceAttributes:attr completionBlock:^(NSArray<MPOFace *> *collection, NSError *error) {
                
                if (error) {
                    NSLog(@"Error: %@", error);
                }
                else {
                    if (collection.count == 0) {
                        return;
                    }
                    NSString *marvelFace;
                    for (MPOFace *face in collection) {
                        marvelFace = [NSString stringWithString:face.faceId];
                        NSLog(@"Marvel: %@", face.faceId);
                        NSLog(@"Marvel: %@", face.attributes.gender);
                        NSLog(@"Marvel: %@", face.attributes.age.stringValue);
                    }
                    [self getSimilarityBetweenFace1:userFace andFace2:marvelFace];//@"36cb342f-f56a-455e-9589-0d8de98d2a67"];
                }
            }];
        }
    }];
}

+ (void)getSimilarityBetweenFace1:(NSString *)faceID1 andFace2:(NSString *)faceID2 {
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:@"a3c7751246144ca296f6ba9cb1dd87e0"];

    [client verifyWithFirstFaceId:faceID1 faceId2:faceID2 completionBlock:^(MPOVerifyResult *verifyResult, NSError *error) {
        
        if (error) {
            NSLog(@"Error: %@", error);
        }
        else {
            NSLog(@"Simiarity:");
            if (verifyResult.isIdentical) {
                NSLog(@"%@", [NSString stringWithFormat:@"The person is the same. The confidence is %@", verifyResult.confidence]);
            }
            else {
                NSLog(@"%@",[NSString stringWithFormat:@"The person is not the same. The confidence is %@", verifyResult.confidence]);
            }
            
        }
        
    }];
}
@end
