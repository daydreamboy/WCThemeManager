//
//  WCStringTool.h
//  WCThemeManager
//
//  Created by wesley_chen on 2018/5/30.
//

#import <Foundation/Foundation.h>

@interface WCStringTool : NSObject
@end

@interface WCStringTool ()

#pragma mark - NSString to Struct/Object

/**
 Safe convert NSString to CGRect
 
 @param string the NSString represents CGRect
 @return the CGRect. If the NSString is malformed, return the CGRectNull
 @warning not allow 0.0, instead of just using 0.
 */
+ (CGRect)rectFromString:(NSString *)string;

/**
 Safe convert NSString to UIEdgeInsets
 
 @param string the NSString represents UIEdgeInsets
 @return the NSValue to wrap UIEdgeInsets, use value.UIEdgeInsets to get UIEdgeInsets
 @warning not allow 0.0, instead of just using 0.
 */
+ (NSValue *)edgeInsetsValueFromString:(NSString *)string;

/**
 Convert hex string to UIColor
 
 @param string the hex string with foramt @"#RRGGBB" or @"#RRGGBBAA"
 @return the UIColor object. return nil if string is not valid.
 */
+ (UIColor *)colorFromHexString:(NSString *)string;

@end
