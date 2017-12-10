//
//  SSItunesApi.m
//  Pods-ss-itunes-api_Example
//
//  Created by wansong on 10/12/2017.
//

#import "SSItunesApi.h"

static NSString *ITUNES_API_BASE = @"https://itunes.apple.com";

@implementation SSItunesApi

+ (void) getAppMetaAppId:(NSString *)appId
                  result:(NullableDictCallback)callback {
  NSMutableDictionary *queries = appId ? [@{@"id": appId} mutableCopy] : [NSMutableDictionary dictionary];
  
  if (!appId) {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    if (bundleId) {
      queries[@"bundleId"] = bundleId;
    }
  }
  queries[@"media"] = @"software";
  
  NSString *urlStr = [self lookUpUriWithQueries:queries];
  NSURL *url = [NSURL URLWithString:urlStr];
  
  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionTask *task = [session dataTaskWithURL:url
         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
           if (error || !data) {
             NSLog(@"url load failed: url(%@), error(%@)", url, error);
             callback(nil);
             return;
           }
           
           NSError *jsonErr = nil;
           NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:data
                                           options:NSJSONReadingAllowFragments
                                             error:&jsonErr];
           if (jsonErr) {
             NSLog(@"failed to json parse: url(%@), data(%@), error(%@)", url, data, jsonErr);
             callback(nil);
             return;
           }
           
           NSDictionary *json = [ret isKindOfClass:NSDictionary.class] ? ret : nil;
           NSArray *results = [json[@"results"] isKindOfClass:NSArray.class] ? json[@"results"] : nil;
           NSDictionary *meta = (NSDictionary *)[results firstObject];
           callback([meta isKindOfClass:NSDictionary.class] ? meta : nil);
         }];
  [task resume];
}

+ (NSString *) queryStringify:(NSDictionary<NSString *, NSString *> *) query {
  NSMutableString *ret = [NSMutableString string];
  [query enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
    [ret appendFormat:@"%@=%@&", key, obj];
  }];
  if (ret.length) {
    [ret deleteCharactersInRange:NSMakeRange(ret.length - 1, 1)];
  }
  return ret;
}

+ (nonnull NSString *) lookUpUriWithQueries: (NSDictionary *) queries {
  NSString *queryStr = [self queryStringify:queries];
  return [NSString stringWithFormat:@"%@/lookup?%@", ITUNES_API_BASE, queryStr];
}

@end
