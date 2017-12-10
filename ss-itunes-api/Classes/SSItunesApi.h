//
//  SSItunesApi.h
//  Pods-ss-itunes-api_Example
//
//  Created by wansong on 10/12/2017.
//

#import <Foundation/Foundation.h>

typedef void(^NullableDictCallback)(NSDictionary * _Nullable info);

@interface SSItunesApi : NSObject

// 如果不提供appId就使用mainbundle identifier
+ (void) getAppMetaAppId:(NSString * _Nullable)appId
                  result:(nonnull NullableDictCallback) callback;
@end
