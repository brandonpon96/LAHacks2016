//
//  ViewController.m
//  LAHacks2016
//
//  Created by Brandon Pon on 4/30/16.
//  Copyright © 2016 Brandon Pon. All rights reserved.
//

#import "ViewController.h"
#import "FaceDetectManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [FaceDetectManager getFaceAttributes];
    [FaceDetectManager getSimilarity];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
