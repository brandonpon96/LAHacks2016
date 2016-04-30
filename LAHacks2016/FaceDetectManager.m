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
+ (void)getFaceAttributes {
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:@"a3c7751246144ca296f6ba9cb1dd87e0"];
    
    [client detectWithUrl:@"http://assets.rollingstone.com/assets/images/story/taylor-swift-cancels-thailand-concert-due-to-political-turbulence-20140527/20140527-taylorswift-x624-1401220626.jpg" returnFaceId:YES returnFaceLandmarks:YES returnFaceAttributes:@[@(MPOFaceAttributeTypeAge), @(MPOFaceAttributeTypeFacialHair), @(MPOFaceAttributeTypeHeadPose), @(MPOFaceAttributeTypeSmile), @(MPOFaceAttributeTypeGender)] completionBlock:^(NSArray<MPOFace *> *collection, NSError *error) {
        
        if (error) {
            NSLog(@"Error: %@", error);
        }
        else {
            NSLog(@"Facial Attributes");
            for (MPOFace *face in collection) {
                NSLog(@"%@", face.attributes.gender);
                NSLog(@"%@", face.attributes.age.stringValue);
            }
        }
    }];
}

+ (void)getSimilarity {
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:@"a3c7751246144ca296f6ba9cb1dd87e0"];

    [client verifyWithFirstFaceId:@"694b87f0-9599-4cbc-a4e8-b144c6bd357f" faceId2:@"7f1d8194-4b5a-412e-a5a5-c7dbdf330dd4" completionBlock:^(MPOVerifyResult *verifyResult, NSError *error) {
        
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
