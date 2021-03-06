//
//  ResultsViewController.m
//  LAHacks2016
//
//  Created by Shannon Phu on 4/30/16.
//  Copyright © 2016 Brandon Pon. All rights reserved.
//

#import "ResultsViewController.h"
#import <UIView+DCAnimationKit.h>
#import "MarvelManager.h"

@interface ResultsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *confidenceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *characterImageView;
@end

@implementation ResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.characterImageView.image = self.characterImage;
    self.characterImageView.contentMode = UIViewContentModeScaleAspectFit;

    self.descriptionLabel.alpha = 0;
    self.confidenceLabel.alpha = 0;
    self.nameLabel.alpha = 0;
    
    self.descriptionLabel.text = self.charDescription;
    self.nameLabel.text = self.charName;
    self.confidenceLabel.text = self.charConfidence;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.characterImageView tada:NULL];
    [self.descriptionLabel bounceIntoView:self.view direction:DCAnimationDirectionLeft];
    [self.confidenceLabel bounceIntoView:self.view direction:DCAnimationDirectionRight];
    [UIView animateWithDuration:0.5 animations:^{
        self.descriptionLabel.alpha = 1;
        self.confidenceLabel.alpha = 1;
        self.nameLabel.alpha = 1;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.characterImageView.image = nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
