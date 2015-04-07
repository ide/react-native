/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "RCTBridgeModuleLoader.h"

#import "RCTBridgeModule.h"
#import "RCTUtils.h"

@implementation RCTBridgeModuleLoader {
  NSMutableArray *_moduleNamesByID;
  NSMutableArray *_moduleClassesByID;
  NSMutableDictionary *_moduleIDsByName;
}

+ (instancetype)sharedLoader
{
  static RCTBridgeModuleLoader *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[RCTBridgeModuleLoader alloc] init];
  });
  return instance;
}

- (instancetype)init
{
  if (self = [super init]) {
    _moduleNamesByID = [NSMutableArray array];
    _moduleClassesByID = [NSMutableArray array];
    _moduleIDsByName = [NSMutableDictionary dictionary];
  }
  return self;
}

- (NSArray *)moduleClassesByModuleID
{
  return _moduleClassesByID;
}

- (NSUInteger)addModuleClass:(Class)moduleClass
{
  NSString *moduleName = RCTModuleNameForClass(moduleClass);
  NSNumber *moduleIDNumber = _moduleIDsByName[moduleName];
  if (moduleIDNumber) {
    return moduleIDNumber.unsignedIntegerValue;
  }

  NSUInteger moduleID = _moduleNamesByID.count;
  _moduleIDsByName[moduleName] = @(moduleID);
  [_moduleNamesByID addObject:moduleName];
  [_moduleClassesByID addObject:moduleClass];
  return moduleID;
}

- (void)loadAllModuleClasses
{
  RCTEnumerateClasses(^(__unsafe_unretained Class cls) {
    if ([cls conformsToProtocol:@protocol(RCTBridgeModule)]) {
      [self addModuleClass:cls];
    }
  });
}

- (NSUInteger)moduleIDForModuleName:(NSString *)moduleName
{
  return ((NSNumber *)_moduleIDsByName[moduleName]).unsignedIntegerValue;
}

- (NSString *)moduleNameForModuleID:(NSUInteger)moduleID
{
  return _moduleNamesByID[moduleID];
}

@end
