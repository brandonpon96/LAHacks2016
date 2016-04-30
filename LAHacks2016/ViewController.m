//
//  ViewController.m
//  LAHacks2016
//
//  Created by Brandon Pon on 4/30/16.
//  Copyright © 2016 Brandon Pon. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import <CommonCrypto/CommonDigest.h>

@interface ViewController ()

@property (strong ,nonatomic) NSString *ts;
@property (strong, nonatomic) NSString *code;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self findMale];
}

- (void)findMale{
    
    self.ts = [self timeStamp];
    
    self.code = [NSString stringWithFormat:@"%@08926590894eb0b868a5853b903e5c831b0fb2965770648b8171f0c6f10d5edb8e640b22",self.ts];
    NSString* hash = [self convertIntoMD5:self.code];
    NSString* request = [NSString stringWithFormat:@"http://gateway.marvel.com:80/v1/public/characters?name=Iron%%20man&ts=%@&apikey=5770648b8171f0c6f10d5edb8e640b22&hash=%@",self.ts,hash];
    NSLog(@"%@",request);
    NSURL *URL = [NSURL URLWithString:request];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (NSString *) timeStamp {
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
}

- (NSString *)convertIntoMD5:(NSString *) string{
    const char *cStr = [string UTF8String];
    unsigned char digest[16];
    
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *resultString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [resultString appendFormat:@"%02x", digest[i]];
    return  resultString;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
