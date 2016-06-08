//
//  FRSJSONResponseSerializer.m
//  Fresco
//
//  Created by Philip Bernstein on 4/27/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSJSONResponseSerializer.h"
#import "FRSGallery.h"
#import "FRSStory.h"
#import "FRSAppDelegate.h"

@implementation FRSJSONResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error {

    id responseToReturn = [super responseObjectForResponse:response
                                                      data:data
                                                     error:error];
    
    NSError *parsingError;
    NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&parsingError];
    
    if (!*error && !parsingError) {
        return [self parsedObjectsFromAPIResponse:JSONResponse cache:TRUE];
    }
    
    
    NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
    NSString *errorDescription = JSONResponse[@"error"];
    userInfo[NSLocalizedDescriptionKey] = errorDescription;
    
    if (parsingError) {
        (*error) = parsingError;
        return responseToReturn;
    }
    
    NSError *annotatedError = [NSError errorWithDomain:(*error).domain
                                                  code:(*error).code
                                              userInfo:userInfo];
    (*error) = annotatedError;
    
    return JSONResponse;
}

-(id)parsedObjectsFromAPIResponse:(id)response cache:(BOOL)cache {
    NSLog(@"RESPONSE CLASS: %@", [response class]);
    
    if ([[response class] isSubclassOfClass:[NSDictionary class]]) {
        NSManagedObjectContext *managedObjectContext =  [self managedObjectContext];//(cache) ? [self managedObjectContext] : Nil;

        NSMutableDictionary *responseObjects = [[NSMutableDictionary alloc] init];
        NSArray *keys = [response allKeys];
        
        for (NSString *key in keys) {
            id valueForKey = [self objectFromDictionary:[response objectForKey:key] context:managedObjectContext];
            
            if (valueForKey == [response objectForKey:key]) {
                return response; // non parse
            }
            
            [responseObjects setObject:valueForKey forKey:key];
        }
        
        if (cache) {
            NSError *saveError;
            [managedObjectContext save:&saveError];
        }
        
        return responseObjects;
    }
    else if ([[response class] isSubclassOfClass:[NSArray class]]) {
        NSMutableArray *responseObjects = [[NSMutableArray alloc] init];
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];//(cache) ? [self managedObjectContext] : Nil;
        
        for (NSDictionary *responseObject in response) {
            id originalResponse = [self objectFromDictionary:responseObject context:managedObjectContext];
            
            if (originalResponse == responseObject) {
                return response;
            }
            
            [responseObjects addObject:[self objectFromDictionary:responseObject context:managedObjectContext]];
        }
        
        if (cache) {
            NSError *saveError;
            [managedObjectContext save:&saveError];
        }
        
        return responseObjects;
    }
    else {
        NSLog(@"No route of serialization. Sry.");
    }
    
    return response;
}

-(id)objectFromDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)managedObjectContext {
    
    if (![dictionary respondsToSelector:@selector(objectForKeyedSubscript:)]) {
        return dictionary;
    }
    
    if ([dictionary isEqual:[NSNull null]]) {
        return dictionary;
    }
    
    NSString *objectType = dictionary[@"object"];
    
    if ([objectType isEqualToString:galleryObjectType]) {
        
        
        FRSGallery *gallery = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:managedObjectContext];
        [gallery configureWithDictionary:dictionary context:managedObjectContext];
        
        return gallery;
    }
    else if ([objectType isEqualToString:postObjectType]) {
        FRSPost *post;
        
        if (managedObjectContext) {
            post = [NSEntityDescription insertNewObjectForEntityForName:@"FRSPost" inManagedObjectContext:managedObjectContext];
        }
        
        [post configureWithDictionary:dictionary context:managedObjectContext];
        
        return post;
        
    }
    else if ([objectType isEqualToString:storyObjectType]) {
        FRSStory *story = [NSEntityDescription insertNewObjectForEntityForName:@"FRSStory" inManagedObjectContext:managedObjectContext];
        [story configureWithDictionary:dictionary];
        
        return story;
    }
    
    return dictionary; // not serializable
}


-(NSManagedObjectContext *)managedObjectContext {
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate managedObjectContext];
}

@end
