//
//  LogStorage.m
//  RevSDK
//
//  Created by Andrey Chernukha on 2/4/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#import "LogStorage.h"

@implementation LogStorage

NSString* localStorageDirectory();

void initDataStorage()
{
    NSString* storageDirectory = localStorageDirectory();
    BOOL exists                = [[NSFileManager defaultManager] fileExistsAtPath:storageDirectory];
    
    if (!exists)
    {
        NSError* error = nil;
        
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:storageDirectory
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:&error];
        
        if (!success)
        {
            NSLog(@"Failed to create storage directory %@", error);
        }
    }
}

NSString* documentsDirectory()
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

NSString* localStorageDirectory()
{
    NSString* docsDirectory    = documentsDirectory();
    NSString* storageDirectory = [docsDirectory stringByAppendingString:@"/logs_storage"];
    
    return storageDirectory;
}

NSString* fullPathForFileName(NSString* aFileName)
{
    NSString* storageDirectory = localStorageDirectory();
    NSString* fullPath         = [storageDirectory stringByAppendingPathComponent:aFileName];
    
    return fullPath;
}


+ (void)save:(NSString *)aString
{
    initDataStorage();
    
    NSDate* now                    = [NSDate date];
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat       = @"yyyy MM dd hh:mm:ss";
    NSString* dateString           = [dateFormatter stringFromDate:now];
    
    NSString* filename = [NSString stringWithFormat:@"%@.dump", dateString];
    NSString* fullPath = fullPathForFileName(filename);
    NSError* error     = nil;
    BOOL success       = [aString writeToFile:fullPath
                                   atomically:YES
                                     encoding:NSUTF8StringEncoding
                                        error:&error];
    
    if (!success)
    {
        NSLog(@"Failed to save dump file %@", error.localizedDescription);
    }
    else
    {
        NSLog(@"Saved successfully!!!!! %@", filename);
    }
}

+ (NSArray*)allDumps
{
    NSString* localStorage = localStorageDirectory();
    NSError* error = nil;
    NSArray* names = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:localStorage
                                                                         error:&error];
    if (!names)
    {
        NSLog(@"Failed to retrieve content %@", error.localizedDescription);
        return nil;
    }
    
    NSMutableArray* dumps = [NSMutableArray array];
    
    for (NSString* name in names)
    {
        NSString* path = fullPathForFileName(name);
        
        NSError* error = nil;
        
        NSString* dump = [NSString stringWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
        
        if (!dump)
        {
            NSLog(@"Failed to retrive dump at path %@ error %@", path, error);
        }
        else
        {
            NSString* filename = [path lastPathComponent];
            
            NSDictionary* dict = @{ filename : dump };
            [dumps addObject:dict];
        }
    }
    
    return dumps;
}

@end
