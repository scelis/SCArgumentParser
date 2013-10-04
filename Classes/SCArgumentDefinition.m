//
//  SCArgumentDefinition.m
//  SCArgumentParser
//
//  Created by Sebastian Celis on 5/16/11.
//  Copyright 2011 Sebastian Celis. All rights reserved.
//

#import "SCArgumentDefinition.h"

@implementation SCArgumentDefinition

#pragma mark - Object Lifecycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _argumentType = SCArgumentTypeUnknown;
        _valueType = SCValueTypeString;
    }

    return self;
}

#pragma mark - Object Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@>{argumentType = %@, returnType = %@, argumentId = %@, shortKeyword = %@, longKeyword = %@, metaName = %@, isRequired = %@, isVariableLength = %@, defaultValue = %@}",
            NSStringFromClass([self class]),
            @([self argumentType]),
            @([self valueType]),
            [self argumentId],
            [self shortKeyword],
            [self longKeyword],
            [self metaName],
            @([self isRequired]),
            @([self isVariableLength]),
            [self defaultValue]];
}

@end
