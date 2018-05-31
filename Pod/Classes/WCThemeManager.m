//
//  WCThemeManager.m
//  WCThemeManager
//
//  Created by wesley_chen on 2018/5/30.
//

#import "WCThemeManager.h"
#import "WCStringTool.h"

/// --- Configuration (plist file)

#define APP_THEME_BUNDLE_NAME   @"WCTheme_CustomerTheme.bundle"
#define THEME_CONFIGURATION_FILENAME   @"theme_configuration.plist"

/// configuration plist keys

// 内置注册默认theme
#define REGISTERED_THEME_NAME_DEFAULT            @"default"
// > required
#define THEME_CONFIGURATION_KEY_FILEPATH            @"filePath" // theme配置文件
// > optional
#define THEME_CONFIGURATION_KEY_PARENT_THEME_NAME   @"parent"   // theme父theme名称
#define THEME_CONFIGURATION_KEY_LAZY_LOAD           @"lazyLoad" // 是否在单例初始化时，加载json文件

/// --- Theme (json file)

/// default theme
#define Pod_RESOURCE_BUNDLE_NAME            @"WCThemeManager.bundle"
#define Pod_THEME_DEFAULT_JSON_FILENAME     @"WCThemeDefault.json"

/// Theme JSON file keys

// 基本key
#define THEME_KEY_COLOR     @"Color"
#define THEME_KEY_IMAGE     @"ImageName"

// 属性key
#define THEME_KEY_ATTR_NAME     @"Name"
#define THEME_KEY_ATTR_INSET    @"Inset"

#pragma mark - C functions for default theme
UIColor* WCThemeColor(NSString *key, UIColor *defaultColor) {
    return [[WCThemeManager sharedInstance].defaultTheme colorForKey:key defaultColor:defaultColor];
}

UIImage* WCThemeImage(NSString *key, UIImage *defaultImage) {
    return [[WCThemeManager sharedInstance].defaultTheme imageForKey:key defaultImage:defaultImage];
}

@interface WCThemeManager ()
@property (nonatomic, strong) NSDictionary *configuration;
@property (nonatomic, strong) NSMutableDictionary<NSString *, WCTheme *> *themes;
@end

@interface WCTheme ()

// configuration
@property (nonatomic, strong) NSDictionary *themeConfiguration;
@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) NSString *filePath;
@property (nonatomic, readwrite) NSString *parentName;
@property (nonatomic, assign, readwrite) BOOL lazyLoad;
@property (nonatomic, assign, readwrite) BOOL loaded;

@property (nonatomic, strong) NSMutableDictionary *themeData;
@property (nonatomic, strong) NSMutableDictionary *themeCaches;

// Caches
@property (nonatomic, strong, readonly) NSCache *cacheColor;
@property (nonatomic, strong, readonly) NSCache *cacheImage;

- (NSMutableDictionary *)loadThemeJSONFileAtPath:(NSString *)path;

@end

@implementation WCThemeManager

#pragma mark - Public Methods

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static WCThemeManager *sInstance;
    dispatch_once(&onceToken, ^{
        sInstance = [[WCThemeManager alloc] init];
        sInstance.themes = [NSMutableDictionary dictionary];
        
        [sInstance loadConfigurationPlistFile];
    });
    return sInstance;
}

- (WCTheme *)defaultTheme {
    return self.themes[REGISTERED_THEME_NAME_DEFAULT];
}

- (WCTheme *)registeredThemeWithName:(NSString *)key {
    WCTheme *theme = self.themes[key];
    
    if (theme.lazyLoad && !theme.loaded) {
        @synchronized (theme) {
            if (theme.lazyLoad && !theme.loaded) {
                [theme.themeData addEntriesFromDictionary:[theme loadThemeJSONFileAtPath:[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:theme.filePath]]];
                theme.loaded = YES;
            }
        }
    }
    
    return theme;
}

#pragma mark -

- (void)loadConfigurationPlistFile {
    NSString *themeConfigurationFilePath = [[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:APP_THEME_BUNDLE_NAME] stringByAppendingPathComponent:THEME_CONFIGURATION_FILENAME];
    if ([[NSFileManager defaultManager] fileExistsAtPath:themeConfigurationFilePath]) {
        self.configuration = [NSDictionary dictionaryWithContentsOfFile:themeConfigurationFilePath];
        
        [self.configuration enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = (NSDictionary *)obj;
                NSString *filePath = dict[THEME_CONFIGURATION_KEY_FILEPATH];
                if ([filePath isKindOfClass:[NSString class]] && filePath.length) {
                    
                    WCTheme *theme;
                    if ([dict[THEME_CONFIGURATION_KEY_LAZY_LOAD] boolValue]) {
                        theme = [[WCTheme alloc] initWithConfiguration:@{}];
                        theme.loaded = NO;
                        theme.lazyLoad = YES;
                    }
                    else {
                        theme = [[WCTheme alloc] initWithJSONFilePath:[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:dict[THEME_CONFIGURATION_KEY_FILEPATH]]];
                        theme.loaded = YES;
                        theme.lazyLoad = NO;
                    }
                    
                    theme.themeConfiguration = dict;
                    theme.name = key;
                    self.themes[theme.name] = theme;
                }
            }
        }];
    }
    
    if (!self.themes[REGISTERED_THEME_NAME_DEFAULT]) {
        NSString *path = [[[NSBundle bundleForClass:self.class].bundlePath stringByAppendingPathComponent:Pod_RESOURCE_BUNDLE_NAME] stringByAppendingPathComponent:Pod_THEME_DEFAULT_JSON_FILENAME];
        WCTheme *defaultTheme = [[WCTheme alloc] initWithJSONFilePath:path];
        defaultTheme.name = REGISTERED_THEME_NAME_DEFAULT;
        self.themes[defaultTheme.name] = defaultTheme;
    }
}

@end

@implementation WCTheme

#pragma mark - Public Methods

- (instancetype)initWithConfiguration:(NSDictionary *)configuration {
    self = [super init];
    if (self) {
        if ([configuration isKindOfClass:[NSDictionary class]]) {
            _themeData = [NSMutableDictionary dictionaryWithDictionary:configuration];
            _themeCaches = [NSMutableDictionary dictionaryWithCapacity:5];
            
            // setup caches for colors, images, ...
            _themeCaches[THEME_KEY_COLOR] = [[NSCache alloc] init];
            _themeCaches[THEME_KEY_IMAGE] = [[NSCache alloc] init];
        }
        else {
            NSLog(@"configuration expect NSDictionary, but it's %@", configuration);
        }
    }
    return self;
}

- (instancetype)initWithJSONFilePath:(NSString *)jsonFilePath {
    NSMutableDictionary *configuration = [self loadThemeJSONFileAtPath:jsonFilePath];
    return [self initWithConfiguration:configuration];
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
        else {
            if (self.parentName) {
                return [[WCThemeManager sharedInstance].themes[self.parentName] colorForKey:key defaultColor:defaultColor];
            }
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
        else {
            // invalid value, just return default
            return defaultImage;
        }
        
        if (imagePath.length) {
            UIImage *image = resizable ? [[UIImage imageNamed:imagePath] resizableImageWithCapInsets:capInset] : [UIImage imageNamed:imagePath];
            if (image) {
                [self.cacheImage setObject:image forKey:key];
                return image;
            }
        }
        else {
            if (self.parentName) {
                return [[WCThemeManager sharedInstance].themes[self.parentName] imageForKey:key defaultImage:defaultImage];
            }
        }
    }
    
    return defaultImage;
}

#pragma mark - Private Methods

- (void)setThemeConfiguration:(NSDictionary *)themeConfiguration {
    _themeConfiguration = themeConfiguration;
    
    if ([_themeConfiguration[THEME_CONFIGURATION_KEY_PARENT_THEME_NAME] isKindOfClass:[NSString class]] &&
        [_themeConfiguration[THEME_CONFIGURATION_KEY_PARENT_THEME_NAME] length]) {
        _parentName = _themeConfiguration[THEME_CONFIGURATION_KEY_PARENT_THEME_NAME];
    }
    
    if ([_themeConfiguration[THEME_CONFIGURATION_KEY_LAZY_LOAD] isKindOfClass:[NSNumber class]]) {
        _lazyLoad = [_themeConfiguration[THEME_CONFIGURATION_KEY_LAZY_LOAD] boolValue];
    }
    
    if ([_themeConfiguration[THEME_CONFIGURATION_KEY_FILEPATH] isKindOfClass:[NSString class]] &&
        [_themeConfiguration[THEME_CONFIGURATION_KEY_FILEPATH] length]) {
        _filePath = _themeConfiguration[THEME_CONFIGURATION_KEY_FILEPATH];
    }
}

#pragma mark > Internal Methods

- (NSMutableDictionary *)loadThemeJSONFileAtPath:(NSString *)path {
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedAlways error:&error];
    if (!data) {
        NSLog(@"read json file failed %@", error);
    }
    
    id jsonObject;
    if (data) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (!jsonObject) {
            NSLog(@"get jsonObject failed %@", error);
        }
        
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            [jsonDict addEntriesFromDictionary:jsonObject];
        }
    }
    
    return jsonDict;
}

#pragma mark > Getters

- (NSCache *)cacheColor {
    return self.themeCaches[THEME_KEY_COLOR];
}

- (NSCache *)cacheImage {
    return self.themeCaches[THEME_KEY_IMAGE];
}

@end
