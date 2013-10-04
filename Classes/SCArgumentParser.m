//
//  SCArgumentParser.m
//  SCArgumentParser
//
//  Created by Sebastian Celis on 5/16/11.
//  Copyright 2011 Sebastian Celis. All rights reserved.
//

#import "SCArgumentParser.h"

#import "SCArgumentDefinition.h"
#import "SCArgumentParserError.h"

@implementation SCArgumentParser

#pragma mark - Object Lifecycle

- (id)init
{
    self = [super init];
    if (self)
    {
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        _processName = [processInfo processName];
        if ([[processInfo arguments] count] > 1)
        {
            // Strip the first argument as it is the path to the executable.
            _arguments = [[processInfo arguments] subarrayWithRange:NSMakeRange(1, [[processInfo arguments] count] - 1)];
        }
    }

    return self;
}

#pragma mark - Accessors

- (void)setArgumentDefinitions:(NSArray *)argumentDefinitions
{
    // Check for invalid argument definitions.
    BOOL foundVariableLengthArg = NO;
    NSMutableSet *argumentIds = [NSMutableSet set];
    NSMutableSet *shortKeywords = [NSMutableSet set];
    NSMutableSet *longKeywords = [NSMutableSet set];
    for (SCArgumentDefinition *argument in argumentDefinitions)
    {
        if ([[argument argumentId] length] == 0)
        {
            [NSException raise:SCArgumentParserGenericException format:@"Invalid argument definition. All arguments must have an argumentId. %@", argument];
        }
        if ([argumentIds containsObject:[argument argumentId]])
        {
            [NSException raise:SCArgumentParserGenericException format:@"Invalid argument definition. Duplicate argumentId found. %@", argument];
        }
        [argumentIds addObject:[argument argumentId]];

        switch ([argument argumentType])
        {
            case SCArgumentTypePositional:
                if (foundVariableLengthArg)
                {
                    [NSException raise:SCArgumentParserGenericException format:@"Invalid argument definition. You can not place any positional arguments after a variable length argument. %@", argument];
                }
                if ([argument valueType] == SCValueTypeBoolean)
                {
                    [NSException raise:SCArgumentParserGenericException format:@"Invalid argument definition. Positional arguments may not have boolean return types. %@", argument];
                }
                if ([argument isVariableLength])
                {
                    foundVariableLengthArg = YES;
                }
                break;
            case SCArgumentTypeKeyword:
                if ([argument isVariableLength])
                {
                    [NSException raise:SCArgumentParserGenericException format:@"Invalid argument definition.Flag arguments may not be of variable length. %@", argument];
                }
                if ([argument valueType] == SCValueTypeBoolean && [argument isRequired])
                {
                    [NSException raise:SCArgumentParserGenericException format:@"Invalid argument definition. Boolean arguments can not be required. %@", argument];
                }
                if ([[argument shortKeyword] length] == 0 && [[argument longKeyword] length] == 0)
                {
                    [NSException raise:SCArgumentParserGenericException format:@"Invalid argument definition. Keyword arguments must either specify a short keyword or a long keyword. %@", argument];
                }
                if ([[argument shortKeyword] length] > 1)
                {
                    [NSException raise:SCArgumentParserGenericException format:@"Invalid argument definition. Short keywords must be a single character in length. %@", argument];
                }
                if ([[argument shortKeyword] length] == 1)
                {
                    if ([shortKeywords containsObject:[argument shortKeyword]])
                    {
                        [NSException raise:SCArgumentParserGenericException format:@"Invalid argument definition. Duplicate short keyword found. %@", argument];
                    }
                    [shortKeywords addObject:[argument shortKeyword]];
                }
                if ([[argument longKeyword] length] == 1)
                {
                    [NSException raise:SCArgumentParserGenericException format:@"Invalid argument definition. Long keywords must be longer than one character. %@", argument];
                }
                if ([[argument longKeyword] length] > 1)
                {
                    if ([longKeywords containsObject:[argument longKeyword]])
                    {
                        [NSException raise:SCArgumentParserGenericException format:@"Invalid argument definition. Duplicate long keyword found. %@", argument];
                    }
                    [longKeywords addObject:[argument longKeyword]];
                }
                break;
            default:
                [NSException raise:SCArgumentParserGenericException format:@"Invalid argument definition: %@. This definition has an unknown argument type.", [argument argumentId]];
                break;
        }
    }

    [self willChangeValueForKey:@"argumentDefinitions"];
    _argumentDefinitions = [argumentDefinitions copy];
    [self didChangeValueForKey:@"argumentDefinitions"];
}

#pragma mark - Public Methods

- (BOOL)parseArgumentsIntoResults:(NSDictionary **)results error:(NSError **)error
{
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSMutableArray *definitions = [[NSMutableArray alloc] initWithCapacity:[[self argumentDefinitions] count]];
    [definitions addObjectsFromArray:[self argumentDefinitions]];

    // Create a number formatter for any numeric arguments.
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:locale];

    // Create the results dictionary
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // Loop through the list of arguments passed into the program.
    BOOL success = YES;
    for (NSUInteger i = 0; i < [[self arguments] count]; i++)
    {
        // Find the argument definition.
        NSString *value = nil;
        NSMutableArray *valueArray = [[NSMutableArray alloc] init];
        SCArgumentDefinition *definition = nil;
        NSString *option = [[self arguments] objectAtIndex:i];
        if ([option hasPrefix:@"--"])
        {
            NSString *flag = [option substringFromIndex:2];
            NSUInteger index = [flag rangeOfString:@"="].location;
            if (index != NSNotFound && index < [flag length])
            {
                value = [flag substringFromIndex:index + 1];
                flag = [flag substringToIndex:index];
                option = [NSString stringWithFormat:@"--%@", flag];
                if (value != nil && [value length] == 0)
                {
                    value = nil;
                }
            }

            for (SCArgumentDefinition *aDefinition in definitions)
            {
                if ([aDefinition argumentType] == SCArgumentTypeKeyword && [[aDefinition longKeyword] isEqualToString:flag])
                {
                    definition = aDefinition;
                    break;
                }
            }
        }
        else if ([option hasPrefix:@"-"])
        {
            NSString *flag = [option substringFromIndex:1];
            for (SCArgumentDefinition *aDefinition in definitions)
            {
                if ([aDefinition argumentType] == SCArgumentTypeKeyword && [[aDefinition shortKeyword] isEqualToString:flag])
                {
                    definition = aDefinition;
                    break;
                }
            }

            if ([definition valueType] != SCValueTypeBoolean && i < [[self arguments] count] - 1)
            {
                i += 1;
                value = [[self arguments] objectAtIndex:i];
                if ([value hasPrefix:@"-"])
                {
                    value = nil;
                }
            }
        }
        else
        {
            for (SCArgumentDefinition *aDefinition in definitions)
            {
                if ([aDefinition argumentType] == SCArgumentTypePositional)
                {
                    definition = aDefinition;
                    break;
                }
            }

            [valueArray addObject:option];
            if ([definition isVariableLength])
            {
                i += 1;
                while (i < [[self arguments] count])
                {
                    [valueArray addObject:[[self arguments] objectAtIndex:i]];
                    i += 1;
                }
            }
        }

        // Unknown option found.
        if (definition == nil)
        {
            success = NO;
            if (error != nil)
            {
                NSString *msg = [NSString stringWithFormat:@"Unknown option: %@", option];
                *error = [NSError errorWithDomain:SCArgumentParserErrorDomain
                                             code:SCArgumentParserErrorCodeInvalidArgument
                                         userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
            }
        }

        // Check for missing or extraneous values.
        if (success)
        {
            if ([definition valueType] == SCValueTypeBoolean)
            {
                if (value != nil)
                {
                    success = NO;
                    if (error != nil)
                    {
                        NSString *msg = [NSString stringWithFormat:@"The option %@ does not accept a value.", option];
                        *error = [NSError errorWithDomain:SCArgumentParserErrorDomain
                                                     code:SCArgumentParserErrorCodeInvalidArgument
                                                 userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                    }
                }
            }
            else if (value == nil && [valueArray count] == 0)
            {
                success = NO;
                if (error != nil)
                {
                    NSString *msg = [NSString stringWithFormat:@"The option %@ requires a value.", option];
                    *error = [NSError errorWithDomain:SCArgumentParserErrorDomain
                                                 code:SCArgumentParserErrorCodeInvalidArgument
                                             userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                }
            }
        }

        // Check for a proper file path.
        if (success && [definition valueType] == SCValueTypeFile)
        {
            NSString *pwd = [environment objectForKey:@"PWD"];
            if (pwd == nil || [pwd length] == 0)
            {
                pwd = @"~/";
            }
            if (![value hasPrefix:@"/"])
            {
                value = [pwd stringByAppendingPathComponent:value];
                value = [value stringByStandardizingPath];
            }
        }

        // Convert return value to proper type.
        id returnValue = nil;
        if (success)
        {
            if ([definition valueType] == SCValueTypeBoolean)
            {
                returnValue = [NSNumber numberWithBool:YES];
            }
            else
            {
                switch ([definition valueType])
                {
                    case SCValueTypeDecimal:
                        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                        break;
                    case SCValueTypeDouble:
                    case SCValueTypeFloat:
                        [formatter setNumberStyle:NSNumberFormatterNoStyle];
                        break;
                    default:
                        break;
                }

                if ([valueArray count] == 0 && value != nil)
                {
                    [valueArray addObject:value];
                }

                for (NSUInteger j = 0; j < [valueArray count] && success; j++)
                {
                    NSString *tmpValue = [valueArray objectAtIndex:j];
                    id convertedValue = tmpValue;
                    switch ([definition valueType])
                    {
                        case SCValueTypeDecimal:
                        case SCValueTypeDouble:
                        case SCValueTypeFloat:
                        {
                            convertedValue = [formatter numberFromString:tmpValue];
                            if (convertedValue == nil)
                            {
                                success = NO;
                                if (error != nil)
                                {
                                    NSString *msg = [NSString stringWithFormat:@"%@ is not a valid number.", tmpValue];
                                    *error = [NSError errorWithDomain:SCArgumentParserErrorDomain
                                                                 code:SCArgumentParserErrorCodeInvalidArgument
                                                             userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                                }
                            }
                            break;
                        }
                        case SCValueTypeInteger:
                        {
                            int intVal = [tmpValue intValue];
                            NSString *intStr = [NSString stringWithFormat:@"%d", intVal];
                            if ([intStr isEqualToString:tmpValue])
                            {
                                convertedValue = [NSNumber numberWithInt:intVal];
                            }
                            else
                            {
                                success = NO;
                                if (error != nil)
                                {
                                    NSString *msg = [NSString stringWithFormat:@"%@ is not a valid integer.", tmpValue];
                                    *error = [NSError errorWithDomain:SCArgumentParserErrorDomain
                                                                 code:SCArgumentParserErrorCodeInvalidArgument
                                                             userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                                }
                            }
                            break;
                        }
                        default:
                            break;
                    }

                    if (success)
                    {
                        [valueArray replaceObjectAtIndex:j withObject:convertedValue];
                    }
                }
            }

            if ([definition isVariableLength])
            {
                returnValue = valueArray;
            }
            else if ([valueArray count] == 1)
            {
                returnValue = [valueArray objectAtIndex:0];
            }
        }

        // Add the value to the results dictionary.
        if (success)
        {
            [definitions removeObject:definition];
            if (returnValue != nil)
            {
                [dict setObject:returnValue forKey:[definition argumentId]];
            }
        }
    }

    // Check for any missing, required arguments.
    if (success)
    {
        for (SCArgumentDefinition *aDefinition in definitions)
        {
            if ([aDefinition isRequired])
            {
                success = NO;
                if (error != nil)
                {
                    NSString *msg;
                    NSString *metaName = [aDefinition metaName];
                    if ([metaName length] == 0)
                    {
                        metaName = [aDefinition argumentId];
                    }
                    if ([aDefinition argumentType] == SCArgumentTypeKeyword)
                    {
                        if ([aDefinition longKeyword] != nil)
                        {
                            msg = [NSString stringWithFormat:@"The option --%@=<%@> is required.", [aDefinition longKeyword], metaName];
                        }
                        else
                        {
                            msg = [NSString stringWithFormat:@"The option -%@ <%@> is required.", [aDefinition shortKeyword], metaName];
                        }
                    }
                    else
                    {
                        msg = [NSString stringWithFormat:@"The option <%@> is required.", metaName];
                    }
                    
                    *error = [NSError errorWithDomain:SCArgumentParserErrorDomain
                                                 code:SCArgumentParserErrorCodeInvalidArgument
                                             userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                }
            }
        }
    }

    // Add default values.
    if (success)
    {
        for (SCArgumentDefinition *aDefinition in definitions)
        {
            if ([aDefinition defaultValue] != nil)
            {
                [dict setObject:[aDefinition defaultValue] forKey:[aDefinition argumentId]];
            }
        }
    }

    // Set the results.
    if (results != nil && success)
    {
        *results = dict;
    }

    return success;
}

@end
