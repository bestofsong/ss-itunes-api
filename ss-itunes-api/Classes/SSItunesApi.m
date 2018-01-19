//
//  SSItunesApi.m
//  Pods-ss-itunes-api_Example
//
//  Created by wansong on 10/12/2017.
//

#import "SSItunesApi.h"

static NSString *ITUNES_API_BASE = @"https://itunes.apple.com";

@interface SSItunesApi ()
@property (strong, nonatomic) NSURLSession *urlSession;
@end

@implementation SSItunesApi

+ (instancetype) sharedInstance {
  static dispatch_once_t onceToken;
  static SSItunesApi *ssia = nil;
  dispatch_once(&onceToken, ^{
    ssia = [SSItunesApi new];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    NSURLSession *ssesion = [NSURLSession sessionWithConfiguration:config];
    ssia.urlSession = ssesion;
  });
  return ssia;
}

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
  NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:url];
  [rq setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36"
forHTTPHeaderField:@"User-Agent"];
  NSURLSession *session = [[self sharedInstance] urlSession];
  NSURLSessionTask *task = [session dataTaskWithRequest:rq
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
           NSLog(@"appstore meta: %@", meta);
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
