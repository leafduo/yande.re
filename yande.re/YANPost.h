//
//  YANPost.h
//  yande.re
//
//  Created by Zuyang Kou on 2/15/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import "MTLModel.h"

@interface YANPost : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSUInteger objectID;
@property (nonatomic, strong) NSURL *previewURL;

@end
