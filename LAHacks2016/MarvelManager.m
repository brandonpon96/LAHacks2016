//
//  MarvelManager.m
//  LAHacks2016
//
//  Created by Brandon Pon on 4/30/16.
//  Copyright © 2016 Brandon Pon. All rights reserved.
//

#import "MarvelManager.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "FaceDetectManager.h"


@implementation MarvelManager

static NSMutableArray * males;
static NSMutableArray * females;
static NSMutableArray * allchars;
NSString *ts;
NSString *code;
NSDictionary *dict;


+(NSArray*) getMales{
    return [males copy];
}

+(NSArray*) getFemales{
    return [females copy];
}

+(NSDictionary*)getMale{
    NSLog(@"male count %d",[males count]);
    if(!males)
        return nil;
    return [males objectAtIndex:(arc4random_uniform([males count]))];
}

+(NSDictionary*)getFemale{
    NSLog(@"female count %d",[females count]);
    if(!females)
        return nil;
    return [females objectAtIndex:(arc4random_uniform([females count]))];
}

+(NSArray*) getCharacters{
    return [allchars copy];
}

+(void)loadCharacters{
    
    males = [[NSMutableArray alloc] init];
    females = [[NSMutableArray alloc] init];
    for(int i = 0; i < 15; i++){
        [self requestCharacters:(i*100)];
    }
}

+(void)maleFemale{
    for(NSDictionary* profile in allchars){
        if([self isMale:[profile valueForKey:@"description"]]){
            [males addObject:profile];
        }
        else{
            [females addObject:profile];
        }
    }
}

+(BOOL)isMale:(NSString*)descript{
    if([descript containsString:@"his"] ||
       [descript containsString:@"he"]  ||
       [descript containsString:@"him"] ||
       [descript containsString:@"man"]){
        return YES;
    }
    return NO;
}


+(void)requestCharacters:(int)offset{
    ts = [self timeStamp];
    allchars =[[NSMutableArray alloc]init];
    
    code = [NSString stringWithFormat:@"%@08926590894eb0b868a5853b903e5c831b0fb2965770648b8171f0c6f10d5edb8e640b22",ts];
    NSString* hash = [self convertIntoMD5:code];
    NSString* request = [NSString stringWithFormat:@"http://gateway.marvel.com:80/v1/public/characters?limit=100&offset=%d&ts=%@&apikey=5770648b8171f0c6f10d5edb8e640b22&hash=%@",offset,ts,hash];
    //NSLog(@"%@",request);
    NSURL *URL = [NSURL URLWithString:request];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        NSDictionary *dictionary = (NSDictionary*) responseObject;
        NSDictionary *data= dictionary[@"data"];
        NSArray *results = data[@"results"];
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
            [allchars addObject:dict];
            // NSLog(@"%@",dict);
        }
        //NSLog(@"%@",allchars);
        [self maleFemale];
        if(offset == 1400){
            NSLog(@"%@",[self getMale]);
            NSLog(@"%@",[self getFemale]);
        }
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

+ (NSString *) timeStamp {
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
}

+ (NSString *)convertIntoMD5:(NSString *) string{
    const char *cStr = [string UTF8String];
    unsigned char digest[16];
    
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *resultString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [resultString appendFormat:@"%02x", digest[i]];
    return  resultString;
}



@end
