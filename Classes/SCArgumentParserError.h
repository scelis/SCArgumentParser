//
//  SCArgumentParserError.h
//  SCArgumentParser
//
//  Created by Sebastian Celis on 5/16/11.
//  Copyright 2011 Sebastian Celis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Well-defined error codes for argument parsing.
 */
typedef NS_ENUM(NSInteger, SCArgumentParserErrorCode) {
    SCArgumentParserErrorCodeGeneric,
    SCArgumentParserErrorCodeInvalidArgument
};

/**
 * The error domain used for all SCArgumentParser errors.
 */
extern NSString * const SCArgumentParserErrorDomain;

/**
 * The name of all SCArgumentParser exceptions.
 */
extern NSString * const SCArgumentParserGenericException;
