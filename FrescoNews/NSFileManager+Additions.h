//
//  NSFileManager+Additions.h
//  Fresco
//
//  Created by Team Fresco on 1/16/14.
//  Copyright (c) 2014 Fresco News. All rights reserved.
//

@import Foundation;

@interface NSFileManager (Additions)

+ (NSString *)uniqueName;
+ (NSString *)documentDirectoryPath;
+ (NSString *)cacheDirectoryPath;
+ (NSString *)libraryDirectoryPath;
+ (NSString *)newUniqueSubdirectoryInDirectoryWithPath:(NSString *)path;
+ (NSString *)pathForUniqueTemporaryFileWithExtension:(NSString*)extension;
+ (NSString *)uniqueSubdirectoryInDocumentsDirectory;
+ (NSString *)uniqueSubdirectoryInTempDirectory;
+ (void)removeFile:(NSURL *)fileURL;
+ (BOOL)replaceFileAtURL:(NSURL *)destinationURL withFileAtURL:(NSURL *)sourceURL;
+ (BOOL)createDirectoryAtPath:(NSString *)path;
+ (BOOL)deleteDirectoryAtPath:(NSString *)path;
+ (BOOL)diskSpaceAvailable:(uint64_t)spaceRequired; // (in bytes)

@end
