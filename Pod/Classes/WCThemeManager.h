//
//  WCThemeManager.h
//  WCThemeManager
//
//  Created by wesley_chen on 2018/5/30.
//

#import <Foundation/Foundation.h>

///--- 获取全局Theme
// 颜色
FOUNDATION_EXPORT UIColor* WCThemeColor(NSString *key, UIColor *defaultColor);
// 图片
FOUNDATION_EXPORT UIImage* WCThemeImage(NSString *key, UIImage *defaultImage);

@interface WCThemeManager : NSObject

+ (instancetype)defaultManager;
- (UIColor *)colorForKey:(NSString *)key defaultColor:(UIColor *)defaultColor;
- (UIImage *)imageForKey:(NSString *)key defaultImage:(UIImage *)defaultImage;

@end
