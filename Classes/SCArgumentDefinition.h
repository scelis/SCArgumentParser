//
//  SCArgumentDefinition.h
//  SCArgumentParser
//
//  Created by Sebastian Celis on 5/16/11.
//  Copyright 2011 Sebastian Celis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The type of argument being defined.
 */
typedef NS_ENUM(NSInteger, SCArgumentType) {
    SCArgumentTypeUnknown,
    SCArgumentTypePositional,
    SCArgumentTypeKeyword
};

/**
 * The type of the value that this argument expects.
 */
typedef NS_ENUM(NSInteger, SCValueType) {
    SCValueTypeUnknown,
    SCValueTypeBoolean,
    SCValueTypeInteger,
    SCValueTypeFloat,
    SCValueTypeDouble,
    SCValueTypeDecimal,
    SCValueTypeString,
    SCValueTypeFile
};

/**
 * SCArgumentDefinition is a basic object representing the definition of a command-line argument.
 * It defines the argument fully so that SCArgumentParser can properly parse it from a list arguments
 * that are passed into a command-line application.
 */
@interface SCArgumentDefinition : NSObject

/**
 * Classifies this argument as a positional argument or an argument represented by a keyword. For
 * |SCValueTypeBoolean| arguments, no value is ever expected for this argument. Instead,
 * merely the existence of the argument will be considered true while the absense of the argument
 * will be considered false.
 */
@property (nonatomic, assign) SCArgumentType argumentType;

/**
 * Describes the type of the variable. Especially useful for parsing arguments into a dictionary
 * of results. Defaults to |SCArgumentTypeUnknown|.
 */
@property (nonatomic, assign) SCValueType valueType;

/**
 * The argument identifier. This will be used for mapping names to values once the argument is
 * fully parsed.
 */
@property (nonatomic, copy) NSString *argumentId;

/**
 * For |SCArgumentTypeKeyword| arguments, this should be a one-character string containing a short
 * version of the flag.
 */
@property (nonatomic, copy) NSString *shortKeyword;

/**
 * For |SCArgumentTypeKeyword| arguments, this should be a longer version of the flag.
 */
@property (nonatomic, copy) NSString *longKeyword;

/**
 * Used in error messages to reference missing arguments.
 */
@property (nonatomic, copy) NSString *metaName;

/**
 * Whether or not the field is required. Defaults to NO.
 */
@property (nonatomic, assign, getter=isRequired) BOOL required;

/**
 * Whether or not the argument definition has a variable number of lexical items associated with it.
 * If this is YES, the argument will consume all of the following parts of the input string. It is
 * not valid to place any positional arguments after an argument of variable length. This BOOL
 * is ignored for |SCArgumentTypeKeyword| arguments.
 */
@property (nonatomic, assign, getter=isVariableLength) BOOL variableLength;

/**
 * The default value for this argument. If this is set and the argument is not specified in the
 * input string, the default value will appear in the parse arguments results dictionary.
 */
@property (nonatomic, strong) id defaultValue;

@end
