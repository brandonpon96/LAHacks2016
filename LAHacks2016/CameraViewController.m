//
//  CameraViewController.m
//  LAHacks2016
//
//  Created by Shannon Phu on 4/30/16.
//  Copyright © 2016 Brandon Pon. All rights reserved.
//

#import "CameraViewController.h"
#import "ImageViewController.h"
#import <LLSimpleCamera.h>
#import "FaceDetectManager.h"
#import <MPOFaceSDK.h>
#import "ResultsViewController.h"
#import <UIView+DCAnimationKit.h>
#import "MarvelManager.h"

@interface CameraViewController ()
@property (strong, nonatomic) UIImage *takenImage;
@property (strong, nonatomic) UIImage *charImage;
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UIButton *snapButton;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIImage *maleImg;
@property (strong, nonatomic) UIImage *femaleImg;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSDictionary *charAttrF;
@property (strong, nonatomic) NSDictionary *charAttrM;
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // camera with precise quality, position and video parameters.
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
                                                 position:LLCameraPositionFront
                                             videoEnabled:NO];
    // attach to the view
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    // ----- camera buttons -------- //
    
    // snap button to capture image
    self.snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.snapButton.frame = CGRectMake(self.view.frame.size.width / 2 - 35.0f, self.view.frame.size.height - 100.0f, 70.0f, 70.0f);
    self.snapButton.clipsToBounds = YES;
    self.snapButton.layer.cornerRadius = self.snapButton.frame.size.width / 2.0f;
    self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.snapButton.layer.borderWidth = 2.0f;
    self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.snapButton.layer.shouldRasterize = YES;
    [self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.snapButton];

    if([LLSimpleCamera isFrontCameraAvailable] && [LLSimpleCamera isRearCameraAvailable]) {
        // button to toggle camera positions
        self.switchButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.switchButton.frame = CGRectMake(0, 0, 29.0f + 20.0f, 22.0f + 20.0f);
        self.switchButton.tintColor = [UIColor whiteColor];
        [self.switchButton setImage:[UIImage imageNamed:@"camera-switch.png"] forState:UIControlStateNormal];
        self.switchButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        [self.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.switchButton];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // start the camera
    [self.camera start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/* camera button methods */

- (void)switchButtonPressed:(UIButton *)button {
    [self.camera togglePosition];
}

- (void)snapButtonPressed:(UIButton *)button {
    [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        if(!error) {
            // We should stop the camera, we are opening a new vc, thus we don't need it anymore.
            // This is important, otherwise you may experience memory crashes.
            // Camera is started again at viewWillAppear after the user comes back to this view.
            // I put the delay, because in iOS9 the shutter sound gets interrupted if we call it directly.
            
            [button expandIntoView:self.view finished:^{
                // Face detection processing                
                //[FaceDetectManager getFaceAttributesWithImage:image];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [self getMaleImage];
                    [self getFemaleImage];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //[self performSegueWithIdentifier:@"showResults" sender:nil];
                    });
                });
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [self getAttr:image];
                });
                
            }];
        }
        else {
            NSLog(@"An error has occured: %@", error);
        }
    } exactSeenImage:YES];
}

- (void)getMaleImage{
    self.charAttrM = [MarvelManager getMale];
    __block NSString *marvelURL = [self.charAttrM valueForKey:@"imageURL"];
    NSLog(@"male: %@", marvelURL);
    NSURL *imageURL = [NSURL URLWithString:marvelURL];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        self.maleImg = [UIImage imageWithData:imageData];
    });
}

- (void)getFemaleImage{
    self.charAttrF = [MarvelManager getFemale];
    __block NSString *marvelURL = [self.charAttrF valueForKey:@"imageURL"];
    NSLog(@"female: %@", marvelURL);
    NSURL *imageURL = [NSURL URLWithString:marvelURL];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        self.femaleImg = [UIImage imageWithData:imageData];
    });
}

- (void)getAttr:(UIImage *)image {
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:@"a3c7751246144ca296f6ba9cb1dd87e0"];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    NSArray *attr = @[@(MPOFaceAttributeTypeGender)];
    
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
//                NSLog(@"User: %@", face.attributes.age.stringValue);
            }
//            __block NSDictionary *character;
            self.gender = userGender;
            self.takenImage = image;
            [self performSegueWithIdentifier:@"showResults" sender:nil];
//            __block NSString *marvelURL = [character valueForKey:@"imageURL"];
            //self.charImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:marvelURL]]];
            
//            NSURL *imageURL = [NSURL URLWithString:marvelURL];
            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    // Update the UI
//                    self.charImage = [UIImage imageWithData:imageData];
//                });
//            });
            
            
            
            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                [client detectWithUrl:marvelURL returnFaceId:YES returnFaceLandmarks:NO returnFaceAttributes:attr completionBlock:^(NSArray<MPOFace *> *collection, NSError *error) {
//                    
//                    if (error) {
//                        NSLog(@"Error: %@", error);
//                    }
//                    else {
//                        if (collection.count == 0) {
//                            return;
//                        }
//                        NSString *marvelFace;
//                        for (MPOFace *face in collection) {
//                            marvelFace = [NSString stringWithString:face.faceId];
//                            NSLog(@"Marvel: %@", face.faceId);
//                            NSLog(@"Marvel: %@", face.attributes.gender);
//                            NSLog(@"Marvel: %@", face.attributes.age.stringValue);
//                        }
//                        [FaceDetectManager getSimilarityBetweenFace1:userFace andFace2:marvelFace];//@"36cb342f-f56a-455e-9589-0d8de98d2a67"];
//                    }
//                }];
//
//            });
        }
    }];

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [self.camera performSelector:@selector(stop) withObject:nil afterDelay:0.2];

    if ([segue.identifier isEqualToString:@"showImage"]) {
        ImageViewController *imgVC = segue.destinationViewController;
        imgVC.image = self.takenImage;
    } else if ([segue.identifier isEqualToString:@"showResults"]) {
        ResultsViewController *resultsVC = segue.destinationViewController;
        NSDictionary *attr;
        if ([self.gender isEqualToString:@"male"]) {
            resultsVC.characterImage = self.maleImg ? self.maleImg : [UIImage imageNamed:@"hero"];
            attr = self.charAttrM;
        } else {
            resultsVC.characterImage = self.femaleImg ? self.femaleImg : [UIImage imageNamed:@"hero"];
            attr = self.charAttrF;
//            resultsVC.characterImage = self.maleImg ? self.maleImg : [UIImage imageNamed:@"hero"];
//            attr = self.charAttrM;
        }
        resultsVC.charName = [attr valueForKey:@"name"];
        resultsVC.charConfidence = @"Confidence: 95%";
        resultsVC.charDescription = [attr valueForKey:@"description"];
    }
}


@end
