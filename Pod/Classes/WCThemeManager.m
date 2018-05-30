//
//  WCThemeManager.m
//  WCThemeManager
//
//  Created by wesley_chen on 2018/5/30.
//

#import "WCThemeManager.h"
#import "WCStringTool.h"

#define APP_THEME_BUNDLE_NAME   @"WCThemeManager_AppTheme.bundle"

// files under APP_THEME_BUNDLE_NAME bundle
#define APP_THEME_THEME_FILENAME   @"AppTheme.json"
#define APP_THEME_SETTING_FILENAME   @"AppSetting.plist"

// 基本key
#define THEME_KEY_COLOR     @"Color"
#define THEME_KEY_IMAGE     @"ImageName"

// 属性key
#define THEME_KEY_ATTR_NAME     @"Name"
#define THEME_KEY_ATTR_INSET    @"Inset"

#pragma mark - C functions for default theme
UIColor* WCThemeColor(NSString *key, UIColor *defaultColor) {
    return [[WCThemeManager defaultManager] colorForKey:key defaultColor:defaultColor];
}

UIImage* WCThemeImage(NSString *key, UIImage *defaultImage) {
    return [[WCThemeManager defaultManager] imageForKey:key defaultImage:defaultImage];
}


@interface WCThemeManager ()
@property (nonatomic, strong) NSMutableDictionary *themeData;
@property (nonatomic, strong) NSMutableDictionary *themeCaches;

// Caches
@property (nonatomic, strong, readonly) NSCache *cacheColor;
@property (nonatomic, strong, readonly) NSCache *cacheImage;
@end

@implementation WCThemeManager

#pragma mark - Public Methods

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static WCThemeManager *sInstance;
    dispatch_once(&onceToken, ^{
        sInstance = [[WCThemeManager alloc] init];
    });
    return sInstance;
}

- (UIColor *)colorForKey:(NSString *)key defaultColor:(UIColor *)defaultColor {
    if ([key isKindOfClass:[NSString class]] && key.length) {
        
        // check cache
        UIColor *cacheColor = [self.cacheColor objectForKey:key];
        if (cacheColor) {
            return cacheColor;
        }
        
        NSString *value = self.themeData[THEME_KEY_COLOR][key];
        UIColor *color = [WCStringTool colorFromHexString:value];
        if (color) {
            [self.cacheColor setObject:color forKey:key];
            return color;
        }
    }
    
    return defaultColor;
}

- (UIImage *)imageForKey:(NSString *)key defaultImage:(UIImage *)defaultImage {
    if ([key isKindOfClass:[NSString class]] && key.length) {
        
        // check cache
        UIImage *cacheImage = [self.cacheImage objectForKey:key];
        if (cacheImage) {
            return cacheImage;
        }
        
        NSString *imagePath = nil;
        UIEdgeInsets capInset = UIEdgeInsetsZero;
        BOOL resizable = NO;
        
        id value = self.themeData[THEME_KEY_IMAGE][key];
        if ([value isKindOfClass:[NSString class]]) {
            imagePath = value;
        }
        else if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)value;
            // check image path
            if ([dict[THEME_KEY_ATTR_NAME] isKindOfClass:[NSString class]]) {
                imagePath = dict[THEME_KEY_ATTR_NAME];
            }
            // check image inset
            NSValue *edgeInsetsValue = [WCStringTool edgeInsetsValueFromString:dict[THEME_KEY_ATTR_NAME]];
            if (edgeInsetsValue) {
                capInset = edgeInsetsValue.UIEdgeInsetsValue;
                resizable = YES;
            }
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            NSArray *arr = (NSArray *)value;
            for (id object in arr) {
                if ([object isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dict = (NSDictionary *)object;
                    // check image path if exists and find the first
                    if ([dict[THEME_KEY_ATTR_NAME] isKindOfClass:[NSString class]]) {
                        NSString *path = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:dict[THEME_KEY_ATTR_NAME]];
                        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                            imagePath = dict[THEME_KEY_ATTR_NAME];
                            NSValue *edgeInsetsValue = [WCStringTool edgeInsetsValueFromString:dict[THEME_KEY_ATTR_NAME]];
                            if (edgeInsetsValue) {
                                capInset = edgeInsetsValue.UIEdgeInsetsValue;
                                resizable = YES;
                            }
                            break;
                        }
                    }
                }
            }
        }
        
        if (imagePath.length) {
            UIImage *image = resizable ? [[UIImage imageNamed:imagePath] resizableImageWithCapInsets:capInset] : [UIImage imageNamed:imagePath];
            if (image) {
                [self.cacheImage setObject:image forKey:key];
                return image;
            }
        }
    }
    
    return defaultImage;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _themeData = [NSMutableDictionary dictionary];
        _themeCaches = [NSMutableDictionary dictionaryWithCapacity:5];
        
        // setup caches for colors, images, ...
        _themeCaches[THEME_KEY_COLOR] = [[NSCache alloc] init];
        _themeCaches[THEME_KEY_IMAGE] = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - Getters

- (NSCache *)cacheColor {
    return self.themeCaches[THEME_KEY_COLOR];
}

- (NSCache *)cacheImage {
    return self.themeCaches[THEME_KEY_IMAGE];
}

@end
