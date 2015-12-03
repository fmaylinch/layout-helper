
#import "ReflectionHelper.h"
//#import "LayoutHelperApp-Swift.h"

// invocation args start at this index
#define ARGS_SHIFT 2

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

- (id) invoke:(SEL)selector on:(id)target args:(NSArray<id>*)args argTypes:(NSArray<NSNumber*>*)argTypes {

    NSMethodSignature* signature = [target methodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    
    [invocation setTarget:target];
    [invocation setSelector:selector];
    
    // Prepare arrays for supported types, to keep references for `setArgument`
    id objects[args.count];
    float floats[args.count];
    double doubles[args.count];
    BOOL booleans[args.count];
    NSInteger integers[args.count];
    
    for (int i=0; i<args.count; i++)
    {
        id arg = args[i];
        
        NSNumber* argTypeObj = argTypes[i];
        ArgType argType = argTypeObj.integerValue;
        
        int index = i + ARGS_SHIFT;
        
        switch (argType) {
                
            case ArgTypeObject:
                objects[i] = arg;
                [invocation setArgument:&objects[i] atIndex:index];
                break;
                
            case ArgTypeInteger:
                integers[i] = ((NSNumber*)arg).integerValue;
                [invocation setArgument:&integers[i] atIndex:index];
                break;

            case ArgTypeFloat:
                floats[i] = ((NSNumber*)arg).floatValue;
                [invocation setArgument:&floats[i] atIndex:index];
                break;
                
            case ArgTypeDouble:
                doubles[i] = ((NSNumber*)arg).doubleValue;
                [invocation setArgument:&doubles[i] atIndex:index];
                break;

            case ArgTypeBool:
                booleans[i] = ((NSNumber*)arg).boolValue;
                [invocation setArgument:&booleans[i] atIndex:index];
                break;

            default:
                [NSException raise:@"Invalid ArgType" format:@"Unexpected ArgType: %ld", (long)argType];
                break;
        }
    }
    
    [invocation invoke];
    
    // TODO: it crashes, maybe because some results are void
    id result = nil;
    // [invocation getReturnValue:&result];
    
    return result;
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
