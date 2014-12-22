//
//  GotyeSDKData.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-13.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeSDKData.h"
#import "GotyeBaseCache.h"
#import "GotyeUser.h"
#import "GotyeSDKConfig.h"
#import "GotyeImageManager.h"
#import "GotyeFileUtil.h"

#define GOTYESDK_DATA_FILE  ([[GotyeFileUtil getCacheDir]stringByAppendingPathComponent:@"user.dat"])

#define GOTYESDK_LOCAL_AVATAR_PATH ([[GotyeFileUtil getCacheDir]stringByAppendingPathComponent:@"avatar"])

@implementation GotyeSDKUserInfo

- (id)initWithUser:(GotyeUser *)user
{
    if (self = [super init]) {
        self.uniqueID = user.uniqueID;
        self.userID = user.userID;
        self.name = user.name;
        self.headValue = user.headValue;
        self.gender = user.gender;
    }
    
    return self;
}

@end

@interface GotyeSDKData()
{
    NSCache *_userInfoCache;
    NSMutableSet *_cachedUserAccount;
    NSMutableArray *_usersToBeUpdated;
    GotyeUser *_localCurrentUserInfo;
    BOOL _avatarModified;
}
@end

@implementation GotyeSDKData

+ (GotyeSDKData *)sharedInstance
{
    return (GotyeSDKData *)[super sharedInstance];
}

- (void)dealloc
{
    [self uninitialize];
}

- (id)init
{
    if (self = [super init]) {
        _userInfoCache = [[NSCache alloc]init];
        _userInfoCache.delegate = self;
        
        _cachedUserAccount = [[NSMutableSet alloc]init];
        _usersToBeUpdated = [[NSMutableArray alloc]init];
    }
    
    return self;
}

- (void)initialize
{
//    _userInfoCache = [[NSCache alloc]init];
//    _userInfoCache.delegate = self;
//    
//    _cachedUserAccount = [[NSMutableSet alloc]init];
//    _usersToBeUpdated = [[NSMutableArray alloc]init];
    
    [GotyeAPI addListener:self type:GotyeAPIListenerTypeUser];
    [GotyeAPI addListener:self type:GotyeAPIListenerTypeLogin];
    [GotyeAPI addListener:self type:GotyeAPIListenerTypeDownload];
}

- (void)destroy
{
    [GotyeAPI removeListener:self];
}

- (GotyeSDKUserInfo *)getUserWithAccount:(NSString *)accountName
{
    GotyeBaseCache *cachedInfo = [_userInfoCache objectForKey:accountName];
    if (cachedInfo && ![cachedInfo isExpired]) {
        return cachedInfo.cachedObject;
    }
    
    if (![_usersToBeUpdated containsObject:accountName]) {
        [GotyeAPI reqUserInfo:accountName];
        [_usersToBeUpdated addObject:accountName];
    }
    
    if (cachedInfo) {
        return cachedInfo.cachedObject;
    }
    
    return nil;
}

- (void)clearCache
{
    _currentUser = nil;
    _localCurrentUserInfo = nil;
    
    [_userInfoCache removeAllObjects];
    [_cachedUserAccount removeAllObjects];
    [_usersToBeUpdated removeAllObjects];
}

- (void)uninitialize
{
    [self clearCache];
    [GotyeAPI removeListener:self];
}

- (void)cacheUserInfo:(GotyeSDKUserInfo *)userInfo withExpiredTime:(NSInteger)seconds
{
    GotyeBaseCache *cache = [_userInfoCache objectForKey:userInfo.uniqueID];
    if (cache == nil) {
        cache = [GotyeBaseCache cacheWithObject:userInfo];
        cache.expiredTime = seconds; //seconds
        [_userInfoCache setObject:cache forKey:userInfo.uniqueID];
        [_cachedUserAccount addObject:userInfo.uniqueID];
    } else {
        [cache resetCachedTime];
        cache.expiredTime = seconds;
        cache.cachedObject = userInfo;
    }
}

- (void)saveCurrentUser
{
    assert(_currentUser.uniqueID);
    
    NSDictionary *infoMap = @{@"accountName": _currentUser.uniqueID,
                              @"avatarURL": (_currentUser.headValue != nil ? _currentUser.headValue : @""),
                              @"userID": @(_currentUser.userID),
                              @"gender": @(_currentUser.gender),
                              @"nickName": (_currentUser.name != nil ? _currentUser.name : @"")};
    
    [infoMap writeToFile:GOTYESDK_DATA_FILE atomically:YES];
    
    _localCurrentUserInfo = _currentUser;
}


- (GotyeUser *)localCurrentUser
{
    if (_localCurrentUserInfo != nil) {
        return _localCurrentUserInfo;
    }
    
    NSDictionary *infoMap = [NSDictionary dictionaryWithContentsOfFile:GOTYESDK_DATA_FILE];
    if (infoMap == nil) {
        return nil;
    }
    
    _localCurrentUserInfo = [[GotyeUser alloc]initWithUniqueID:infoMap[@"accountName"]];
    _localCurrentUserInfo.headValue = infoMap[@"avatarURL"];
    _localCurrentUserInfo.gender = [infoMap[@"gender"]intValue];
    _localCurrentUserInfo.name = infoMap[@"nickName"];
    _localCurrentUserInfo.userID = [infoMap[@"userID"]intValue];
    
    return _localCurrentUserInfo;
}

- (BOOL)needToModifyBaseUserInfo
{
    if ([self localCurrentUser] == nil) {
        return YES;
    }

    GotyeUser *local = [self localCurrentUser];
    
    assert([local.uniqueID isEqualToString:_currentUser.uniqueID]);
    
    return !((local.name == [GotyeSDKConfig sharedInstance].userNickName || [local.name isEqualToString:[GotyeSDKConfig sharedInstance].userNickName]) && (local.gender == [GotyeSDKConfig sharedInstance].userGender));
}

- (BOOL)needToModifyAvatar
{
    if ([self localCurrentUser] == nil) {
        return YES;
    }
    
    if ([GotyeSDKConfig sharedInstance].userAvatar == nil) {
        return NO;
    }
    
    GotyeUser *local = [self localCurrentUser];
    
    assert([local.uniqueID isEqualToString:_currentUser.uniqueID]);
    
    NSData *localAvatarData = [NSData dataWithContentsOfFile:GOTYESDK_LOCAL_AVATAR_PATH];
    NSData *mofityToAvatarData = UIImageJPEGRepresentation([GotyeSDKConfig sharedInstance].userAvatar, 1);
    
    return !(localAvatarData == mofityToAvatarData || [localAvatarData isEqualToData:mofityToAvatarData]);
}

#pragma mark - user delegate -

- (void)onGetUserInfo:(GotyeUser *)user result:(GotyeStatusCode)status
{
    [_usersToBeUpdated removeObject:user.uniqueID];
    
    if (status != GotyeStatusCodeOK) {
        return;
    }
    
    GotyeSDKUserInfo *sdkUserInfo = [(GotyeBaseCache *)[_userInfoCache objectForKey:user.uniqueID]cachedObject];
    if (sdkUserInfo != nil) {
        sdkUserInfo.name = user.name;
        sdkUserInfo.gender = user.gender;
        sdkUserInfo.userID = user.userID;
        sdkUserInfo.headValue = user.headValue;
    } else {
        sdkUserInfo = [[GotyeSDKUserInfo alloc]initWithUser:user];
    }
    
    UIImage *newAvatar = [[GotyeImageManager sharedImageManager]getImageWithPath:sdkUserInfo.headValue];
    if (newAvatar != nil) {
        sdkUserInfo.userAvatar = newAvatar;
    }
    
    if ([user.uniqueID isEqualToString:[GotyeSDKConfig sharedInstance].userAccount]) {
        _currentUser = sdkUserInfo;

        [self cacheUserInfo:_currentUser withExpiredTime:0];

        _avatarModified = [self needToModifyAvatar];
        if ([self needToModifyBaseUserInfo] || _avatarModified) {
            GotyeSDKUserInfo *modifyUser = [[GotyeSDKUserInfo alloc]initWithUniqueID:_currentUser.uniqueID];
            modifyUser.userID = _currentUser.userID;
            modifyUser.headValue = _currentUser.headValue;
            modifyUser.name = [GotyeSDKConfig sharedInstance].userNickName;
            modifyUser.gender = [GotyeSDKConfig sharedInstance].userGender;
            if (_avatarModified) {
                modifyUser.userAvatar = [GotyeSDKConfig sharedInstance].userAvatar;
            }
            
            [GotyeAPI modifyUserInfo:modifyUser withAvatar:modifyUser.userAvatar];
        }
    } else {
        [self cacheUserInfo:sdkUserInfo withExpiredTime:120];
    }
}

- (void)onModifyUserInfo:(GotyeUser *)user result:(GotyeStatusCode)status
{
    if (status != GotyeStatusCodeOK) {
        return;
    }
    
    _currentUser.name = user.name;
    _currentUser.gender = user.gender;

    //保存修改的图片到本地，下次想要修改时先判断
    if (_avatarModified) {
        _currentUser.headValue = user.headValue;
        UIImage *newAvatar = [[GotyeImageManager sharedImageManager]getImageWithPath:user.headValue];
        if (newAvatar != nil) {
            _currentUser.userAvatar = newAvatar;
        }
        
        if (![[NSFileManager defaultManager]fileExistsAtPath:GOTYESDK_LOCAL_AVATAR_PATH]) {
            [[NSFileManager defaultManager]createFileAtPath:GOTYESDK_LOCAL_AVATAR_PATH contents:nil attributes:nil];
        }
        
        NSData *data = UIImageJPEGRepresentation([GotyeSDKConfig sharedInstance].userAvatar, 1);
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:GOTYESDK_LOCAL_AVATAR_PATH];
        [file writeData:data];
        [file closeFile];
    }
    
    [self saveCurrentUser];

    [self cacheUserInfo:_currentUser withExpiredTime:0];
}

#pragma mark - login delegate -

- (void)onLoginResp:(GotyeStatusCode)statusCode account:(NSString *)account appKey:(NSString *)appKey
{
    if (statusCode != GotyeStatusCodeOK) {
        return;
    }
    
    _currentUser = [self getUserWithAccount:[GotyeSDKConfig sharedInstance].userAccount];
    if (_currentUser == nil) {
        _currentUser = [[GotyeSDKUserInfo alloc]initWithUniqueID:account];
    }
}

#pragma mark - download delegate -

- (void)onDownloadRes:(NSString *)downloadURL path:(NSString *)savedPath result:(GotyeStatusCode)status
{
    if (status != GotyeStatusCodeOK) {
        return;
    }
    
    for (NSString *userAccount in _cachedUserAccount ) {
        GotyeSDKUserInfo *cache = [(GotyeBaseCache *)[_userInfoCache objectForKey:userAccount]cachedObject];
        if (cache == nil || ![cache.headValue isEqualToString:downloadURL]) {
            continue;
        }
        
        cache.userAvatar = [[GotyeImageManager sharedImageManager]getImageWithPath:savedPath];
    }
}

#pragma mark - NSCache Delegate -

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    if (cache != _userInfoCache) {
        return;
    }
    NSString *account = ((GotyeUser *)((GotyeBaseCache *)obj).cachedObject).uniqueID;
    [_cachedUserAccount removeObject:account];
}
@end
