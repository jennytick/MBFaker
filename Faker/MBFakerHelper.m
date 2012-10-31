//
//  MBFakerHelper.m
//  Faker
//
//  Created by Michał Banasiak on 10/29/12.
//  Copyright (c) 2012 Michał Banasiak. All rights reserved.
//

#import "MBFakerHelper.h"
#import "YAML.framework/Headers/YAMLSerialization.h"

@implementation MBFakerHelper

+ (NSDictionary*)translations {
    NSMutableDictionary* translationsDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSArray* translationPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"yml" inDirectory:@""];
    
    for (NSString* path in translationPaths) {
        NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath: path];
        
        
        NSMutableArray* yaml = [YAMLSerialization YAMLWithStream: stream
                                                         options: kYAMLReadOptionStringScalars
                                                           error: nil];
        
        NSDictionary* dictionary = (NSDictionary*)[yaml objectAtIndex:0];
        
        NSString* key = [[dictionary allKeys] objectAtIndex:0];
        
        [translationsDictionary setObject: [dictionary objectForKey:key] forKey:key];
    }
    
    return (NSDictionary*)translationsDictionary;
}

+ (NSDictionary*)dictionaryForLanguage:(NSString*)language {
    NSDictionary* dictionary = [[MBFakerHelper translations] objectForKey:language];
    
    return [dictionary objectForKey:@"faker"];
}

+ (NSArray*)fetchDataWithKey:(NSString*)key withLanguage:(NSString*)language {
    NSDictionary* dictionary = [MBFakerHelper dictionaryForLanguage:language];
    
    NSArray* parsedKey = [key componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    
    if ([parsedKey count] == 1)
        return [dictionary objectForKey:key];
    else {
        id parsedObject = [dictionary objectForKey:[parsedKey objectAtIndex:0]];
        
        for (int i=1; i<[parsedKey count]; i++)
            parsedObject = [parsedObject objectForKey:[parsedKey objectAtIndex:i]];
        
        return (NSArray*)parsedObject;
    }
    
    return nil;
}

+ (NSString*)fetchRandomElementWithKey:(NSString*)key withLanguage:(NSString*)language {
    NSString* lowercaseKey = [key lowercaseString];
    
    NSArray* elements = [MBFakerHelper fetchDataWithKey:lowercaseKey withLanguage:language];
    
    if ([elements count] > 0) {
        NSInteger randomIndex = arc4random() % [elements count];
        
        NSString* fetchedString = [elements objectAtIndex:randomIndex];
        
        return [MBFakerHelper fetchDataWithTemplate:fetchedString withLanguage:language];
    }
    
    return nil;
}

+ (NSString*)fetchDataWithTemplate:(NSString*)dataTemplate withLanguage:(NSString*)language {
    NSArray* components = [dataTemplate componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{#}"]];
    
    NSMutableArray* parsedTemplate = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSString* component in components)
        if ([component length] > 0)
            [parsedTemplate addObject:component];
    
    if ([parsedTemplate count] == 1)
        return [parsedTemplate objectAtIndex:0];
    else {
        NSString* fetchedString = @"";
        
        for (NSString* parsedElement in parsedTemplate) {
            if ([parsedElement compare:@" "] == 0)
                fetchedString = [fetchedString stringByAppendingString:@" "];
            else {
                NSString* stringToAppend = [MBFakerHelper fetchRandomElementWithKey:parsedElement withLanguage:language];
            
                fetchedString = [fetchedString stringByAppendingString:stringToAppend];
            }
                
        }
        
        if ([fetchedString compare:@""] == 0)
            return nil;
        else
            return fetchedString;
    }
    
    return nil;
}

@end
