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

@interface WCTheme : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *filePath;
@property (nonatomic, copy, readonly) NSString *parentName;
@property (nonatomic, assign, readonly) BOOL lazyLoad;

- (instancetype)initWithConfiguration:(NSDictionary *)configuration;
- (instancetype)initWithJSONFilePath:(NSString *)jsonFilePath;

- (UIColor *)colorForKey:(NSString *)key defaultColor:(UIColor *)defaultColor;
- (UIImage *)imageForKey:(NSString *)key defaultImage:(UIImage *)defaultImage;

// Deprecated
- (instancetype)init NS_UNAVAILABLE;

@end
