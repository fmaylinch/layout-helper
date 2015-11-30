
#import "ReflectionHelper.h"
//#import "LayoutHelperApp-Swift.h"

@implementation ReflectionHelper

+ (id) getProperty:(NSString*)name target:(NSObject*)target {
    return [target valueForKey:name];
}

+ (void) setProperty:(NSString*)name value:(id)value target:(NSObject*)target {

    NSLog(@"Setting property %@", name);
    [target setValue:value forKey:name];
}

+ (id) instanceFromClass:(NSString*)clazz {
    return [[NSClassFromString(clazz) alloc] init];
}

- (instancetype) initWithObjects:(NSMutableDictionary*)objects {
    self.objects = objects;
    return self;
}

- (void) performAssignment:(NSString*)target value:(NSString*)value {
    
    NSArray<NSString*>* parts = [target componentsSeparatedByString:@"."];
    
    if (parts.count < 2) {
        NSLog(@"Expected at least one dot `.` separating the properties but found: %@", target);
    }
    
    NSObject* object = self.objects[parts[0]];
    
    if (object == nil) {
        NSLog(@"Object with name `%@` not found!", parts[0]);
        return;
    }
    
    for (int i=1; i<parts.count-1; i++) {
        object = [ReflectionHelper getProperty:parts[i] target:object];
        if (object == nil) {
            NSLog(@"Property with name `%@` not found!", parts[i]);
            return;
        }
    }
    
    id parsedValue = [self parseValue:value];
    
    [ReflectionHelper setProperty:parts[parts.count-1] value:parsedValue target:object];
}

- (id) parseValue:(NSString*)value {
    
    unichar c = [value characterAtIndex:0];

    // number
    if (c >= '0' && c <= '9') {
        if ([value containsString:@"."]) {
            return @([value floatValue]);
        } else {
            return @([value integerValue]);
        }
        
    // boolean
    } else if ([value isEqualToString:@"true"]) {
        return [NSNumber numberWithBool:YES];
    } else if ([value isEqualToString:@"false"]) {
        return [NSNumber numberWithBool:NO];
        
    // string
    } else if (c == '"') {
        // skip quotes
        value = [value substringWithRange:NSMakeRange(1, value.length-2)];
        // replace literal "\n"
        value = [value stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        return value;
    
    // variable
    } else {
        
        NSObject* object = self.objects[value];
        
        if (object == nil) {
            NSLog(@"Object with name `%@` not found!", value);
            return nil;
        }

        return object;
    }
}


@end
