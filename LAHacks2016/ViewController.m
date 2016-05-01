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
#import "FaceDetectManager.h"

@interface ViewController ()

@property (strong ,nonatomic) NSString *ts;
@property (strong, nonatomic) NSString *code;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //[FaceDetectManager getFaceAttributesWithImage:[UIImage imageNamed:@"taylor"]];
    [self findMale];
}

- (void)findMale{
    
    self.ts = [self timeStamp];
    
    self.code = [NSString stringWithFormat:@"%@08926590894eb0b868a5853b903e5c831b0fb2965770648b8171f0c6f10d5edb8e640b22",self.ts];
    NSString* hash = [self convertIntoMD5:self.code];
    NSString* request = [NSString stringWithFormat:@"http://gateway.marvel.com:80/v1/public/characters?limit=100&ts=%@&apikey=5770648b8171f0c6f10d5edb8e640b22&hash=%@",self.ts,hash];
    NSLog(@"%@",request);
    NSURL *URL = [NSURL URLWithString:request];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        NSDictionary *dictionary = (NSDictionary*) responseObject;
        NSDictionary *data= dictionary[@"data"];
        NSArray *results = data[@"results"];
        NSMutableArray * characters = [[NSMutableArray alloc]init];
        NSDictionary* dict;
        for(NSDictionary* dic in results){
            if([dic[@"description"] isEqualToString:@""] || [[dic valueForKeyPath:@"thumbnail.path"] containsString:@"image_not_available"])
                continue;
            
            NSMutableString *imgURLPath = [dic valueForKeyPath:@"thumbnail.path"];
            NSString *urlExtension = [dic valueForKeyPath:@"thumbnail.extension"];
            NSString *imgURL = [NSString stringWithFormat:@"%@.%@", imgURLPath, urlExtension];
            dict = @{
                     @"name":[dic objectForKey:@"name"],
                     @"description":[dic objectForKey:@"description"],
                     @"imageURL": imgURL
                     };
            [characters addObject:dict];
            NSLog(@"%@", dict);
            //[FaceDetectManager getFaceAttributesWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]]]];
        }

        //NSLog(@"%@",dict);
       
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
