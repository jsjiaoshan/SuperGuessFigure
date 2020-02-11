//
//  QuestionModel.h
//  SuperGuessFigure
//
//  Created by 焦珊 on 2020/2/9.
//  Copyright © 2020 焦珊. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QuestionModel : NSObject
@property (nonatomic,copy) NSString *answer;
@property(nonatomic, copy) NSString *icon;
@property(nonatomic, copy) NSString *title;
@property (nonatomic,strong) NSArray *options;

- (instancetype) initWithDict:(NSDictionary *)dict;
+(instancetype) QuestionWithDict:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
