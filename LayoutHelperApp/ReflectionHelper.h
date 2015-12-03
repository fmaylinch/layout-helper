
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ArgType) {
    ArgTypeObject,
    ArgTypeInteger,
    ArgTypeFloat,
    ArgTypeDouble,
    ArgTypeBool
};

@interface ReflectionHelper : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString*,NSObject*>* objects;

/** Gets property. It's like: return target.name; */
+ (id) getProperty:(NSString*)name target:(NSObject*)target;

/** Sets property. It's like: target.name = value; */
+ (void) setProperty:(NSString*)name value:(id)value target:(NSObject*)target;

/** Creates an instance from the given class */
+ (id) instanceFromClass:(NSString*)clazz;

- (instancetype) initWithObjects:(NSMutableDictionary<NSString*,NSObject*>*)objects;

- (id) invoke:(SEL)selector on:(id)target args:(NSArray<id>*)args argTypes:(NSArray<NSNumber*>*)argTypes;

/** 
 * Parses and executes an assignment like "target = value"
 * `target` must be a variable with chained properties like: variable.property.property...
 */
- (void) performAssignment:(NSString*)target value:(NSString*)value;

@end
