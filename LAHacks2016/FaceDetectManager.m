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

@implementation FaceDetectManager

+ (void)getFaceAttributesWithImage:(UIImage *)image {
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:@"a3c7751246144ca296f6ba9cb1dd87e0"];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    
    [client detectWithData:imageData returnFaceId:YES returnFaceLandmarks:NO returnFaceAttributes:@[@(MPOFaceAttributeTypeAge), @(MPOFaceAttributeTypeFacialHair), @(MPOFaceAttributeTypeHeadPose), @(MPOFaceAttributeTypeSmile), @(MPOFaceAttributeTypeGender)] completionBlock:^(NSArray<MPOFace *> *collection, NSError *error) {
        
        if (error) {
            NSLog(@"Error: %@", error);
        }
        else {
            NSLog(@"Facial Attributes");
            for (MPOFace *face in collection) {
                NSLog(@"%@", face.faceId);
                NSLog(@"%@", face.attributes.gender);
                NSLog(@"%@", face.attributes.age.stringValue);
                
                [self getSimilarityBetweenFace1:face.faceId andFace2:@"36cb342f-f56a-455e-9589-0d8de98d2a67"];
            }
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
