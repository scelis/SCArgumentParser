//
//  SCArgumentParser.h
//  SCArgumentParser
//
//  Created by Sebastian Celis on 5/16/11.
//  Copyright 2011 Sebastian Celis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This class parses command-line arguments into a dictionary of name-value pair results.
 */
@interface SCArgumentParser : NSObject

/**
 * The name of the process. Defaults to the one used to launch the current process.
 */
@property (nonatomic, copy) NSString *processName;

/**
 * The arguments to parse. Defaults to the arguments passed into the current process. This is an
 * array of NSStrings.
 */
@property (nonatomic, copy) NSArray *arguments;

/**
 * Help text to show the user. Can contain one (or more) usage lines, a description of the program,
 * and a list of possible arguments.
 */
@property (nonatomic, copy) NSString *helpText;

/**
 * A well-defined list of arguments that are accepted by this parser. This should be an array of
 * |SCArgumentDefinition| objects. Setting this to an array that contains an invalid array of
 * argument definitions will cause an NSException to be raised.
 */
@property (nonatomic, copy) NSArray *argumentDefinitions;

/**
 * The main method that does all of the argument parsing.
 * @param results On success, this parameter will point to a dictionary where the results of the
 * parsing operation can be found.
 * @param error On failure, this parameter will point to an NSError object describing the failure.
 * @return YES if the arguments were successfully parsed. NO if the parsing failed.
 */
- (BOOL)parseArgumentsIntoResults:(NSDictionary **)results error:(NSError **)error;

@end
