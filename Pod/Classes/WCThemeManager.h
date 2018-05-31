//
//  WCThemeManager.h
//  WCThemeManager
//
//  Created by wesley_chen on 2018/5/30.
//

#import <Foundation/Foundation.h>

///--- 获取默认Theme
// 颜色
FOUNDATION_EXPORT UIColor* WCThemeColor(NSString *key, UIColor *defaultColor);
// 图片
FOUNDATION_EXPORT UIImage* WCThemeImage(NSString *key, UIImage *defaultImage);

@class WCTheme;

@interface WCThemeManager : NSObject

+ (instancetype)sharedInstance;

- (WCTheme *)defaultTheme;
- (WCTheme *)registeredThemeWithName:(NSString *)key;

@end

typedef NS_ENUM(NSUInteger, WCThemeUpdatePolicy) {
    /*! 合并模式更新，集合new合并到集合old，相同元素被替换 */
    WCThemeUpdatePolicyMerge,
    /*! 替换模式更新，集合new完全替换集合old */
    WCThemeUpdatePolicyReplace,
};

FOUNDATION_EXPORT NSNotificationName WCThemeDidUpdateNotification;
FOUNDATION_EXPORT NSString *WCThemeDidUpdateNotificationKeyUpdatePolicy;

@interface WCTheme : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *filePath;
@property (nonatomic, copy, readonly) NSString *parentName;
@property (nonatomic, assign, readonly) BOOL lazyLoad;

- (instancetype)initWithConfiguration:(NSDictionary *)configuration;
- (instancetype)initWithJSONFilePath:(NSString *)jsonFilePath;

/**
 更新Theme配置
 
 @param configuration 新的Theme配置
 @param updatePolicy 更新策略，有两种合并模式（WCThemeUpdatePolicyMerge）和替换模式（WCThemeUpdatePolicyReplace）
    - WCThemeUpdatePolicyMerge，存在相同key，value进行覆盖
    - WCThemeUpdatePolicyReplace，如果UI属性没有配置（例如configuration中没有Color键），则不进行替换；如果UI属性配置为空或者有值，则进行替换
 @return YES，更新成功；NO，更新失败
 */
- (BOOL)updateConfiguration:(NSDictionary *)configuration withPolicy:(WCThemeUpdatePolicy)updatePolicy;

- (UIColor *)colorForKey:(NSString *)key defaultColor:(UIColor *)defaultColor;
- (UIImage *)imageForKey:(NSString *)key defaultImage:(UIImage *)defaultImage;

// Deprecated
- (instancetype)init NS_UNAVAILABLE;

@end
