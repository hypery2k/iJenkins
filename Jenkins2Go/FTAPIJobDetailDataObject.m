//
//  FTAPIJobDetailDataObject.m
//  iJenkins
//
//  Created by Ondrej Rafaj on 30/08/2013.
//  Copyright (c) 2013 Fuerte Innovations. All rights reserved.
//

#import "FTAPIJobDetailDataObject.h"


@interface FTAPIJobDetailDataObject ()

@property (nonatomic, strong) NSString *jobName;
@property (nonatomic, strong) NSString *jobMethod;

@end


@implementation FTAPIJobDetailDataObject


#pragma mark Object implementation

- (FTHttpMethod)httpMethod {
    return FTHttpMethodGet;
}

- (NSString *)methodName {
    return  _jobMethod;
}

- (NSDictionary *)payloadData {
    return nil;
}

- (void)processData:(NSDictionary *)data {
    [super processData:data];
    
    _displayName = data[@"displayName"];
    _name = [data[@"name"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _url = data[@"url"];
    _desc = data[@"description"];
    _buildable = [data[@"buildable"] boolValue];
    
    NSInteger count = [data[@"builds"] count];
    if (count > 0) {
        int x = 0;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
        for (NSDictionary *d in data[@"builds"]) {
            FTAPIJobDetailBuildDataObject *build = [[FTAPIJobDetailBuildDataObject alloc] init];
            [build processData:d];
            [arr addObject:build];
            x++;
        }
        _builds = [NSArray arrayWithArray:arr];
    }
    
    _lastBuild = [[FTAPIJobDetailBuildDataObject alloc] init];
    [_lastBuild processData:data[@"lastBuild"]];
    
    _lastFailedBuild = [[FTAPIJobDetailBuildDataObject alloc] init];
    [_lastFailedBuild processData:data[@"lastFailedBuild"]];
    
    _lastSuccessfulBuild = [[FTAPIJobDetailBuildDataObject alloc] init];
    [_lastSuccessfulBuild processData:data[@"lastSuccessfulBuild"]];
    
    _lastUnstableBuild = [[FTAPIJobDetailBuildDataObject alloc] init];
    [_lastUnstableBuild processData:data[@"lastUnstableBuild"]];
    
    _lastUnsuccessfulBuild = [[FTAPIJobDetailBuildDataObject alloc] init];
    [_lastUnsuccessfulBuild processData:data[@"lastUnsuccessfulBuild"]];
    
    _firstBuild = [[FTAPIJobDetailBuildDataObject alloc] init];
    [_firstBuild processData:data[@"firstBuild"]];
    
    count = [data[@"healthReport"] count];
    if (count > 0) {
        int x = 0;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
        for (NSDictionary *d in data[@"healthReport"]) {
            FTAPIJobDetailHealthDataObject *healthReport = [[FTAPIJobDetailHealthDataObject alloc] init];
            [healthReport processData:d];
            if (x == 0) {
                _healthReport = healthReport;
            }
            [arr addObject:healthReport];
            x++;
        }
        _healthReports = [NSArray arrayWithArray:arr];
    }
}

#pragma mark Initialization

- (id)initWithJobName:(NSString *)jobName jobMethod:(NSString *)jobMethod {
    self = [super init];
    if (self) {
        _jobName = jobName;
        _jobMethod = jobMethod;
    }
    return self;
}


@end


@implementation FTAPIJobDetailBuildDataObject

#pragma mark Data

- (void)processData:(NSDictionary *)data {
    if (!data || [data isKindOfClass:[NSNull class]]) return;
    _number = [data[@"number"] integerValue];
    _urlString = data[@"url"];
}

- (void)loadBuildDetailWithSuccessBlock:(void (^)(FTAPIBuildDetailDataObject *))success forJobName:(NSString *)jobName jobMethod:(NSString *)jobMethod {
    if (_isLoading) return;
    _isLoading = YES;
    FTAPIBuildDetailDataObject *buildObject = [[FTAPIBuildDetailDataObject alloc] initWithJobName:jobName jobMethod:jobMethod andBuildNumber:_number];
    [FTAPIConnector connectWithObject:buildObject andOnCompleteBlock:^(id<FTAPIDataAbstractObject> dataObject, NSError *error) {
        _buildDetail = buildObject;
        if (success) {
            success(buildObject);
        }
        _isLoading = NO;
    }];
}


@end


@implementation FTAPIJobDetailHealthDataObject

#pragma makr Data

- (void)processData:(NSDictionary *)data {
    _score = [data[@"score"] integerValue];
    _iconUrl = data[@"iconUrl"];
    _desc = data[@"description"];
}


@end
