//
//  QuestionModel.m
//  SuperGuessFigure
//
//  Created by 焦珊 on 2020/2/9.
//  Copyright © 2020 焦珊. All rights reserved.
//

#import "QuestionModel.h"

@implementation QuestionModel
- (instancetype) initWithDict:(NSDictionary *)dict{
    self = [super init];
    if(self){
        self.answer = dict[@"answer"];
        self.title = dict[@"title"];
        self.icon = dict[@"icon"];
        self.options = dict[@"options"];
    }
    return self;
}
+(instancetype) QuestionWithDict:(NSDictionary *)dict{
    return  [[self alloc]initWithDict:dict];
}

@end
