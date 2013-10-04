//
//  main.m
//  SCArgumentParserExample
//
//  Created by Sebastian Celis on 10/4/13.
//  Copyright (c) 2013 Sebastian Celis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCArgumentDefinition.h"
#import "SCArgumentParser.h"
#import "SCArgumentParserError.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        SCArgumentDefinition *definition;
        NSMutableArray *definitions = [[NSMutableArray alloc] init];
        
        definition = [[SCArgumentDefinition alloc] init];
        [definition setArgumentId:@"testBoolean"];
        [definition setArgumentType:SCArgumentTypeKeyword];
        [definition setValueType:SCValueTypeBoolean];
        [definition setShortKeyword:@"a"];
        [definition setLongKeyword:@"test-boolean"];
        [definition setMetaName:@"boolean"];
        [definitions addObject:definition];

        definition = [[SCArgumentDefinition alloc] init];
        [definition setArgumentId:@"testInteger"];
        [definition setArgumentType:SCArgumentTypeKeyword];
        [definition setValueType:SCValueTypeInteger];
        [definition setShortKeyword:@"b"];
        [definition setLongKeyword:@"test-integer"];
        [definition setMetaName:@"integer"];
        [definition setDefaultValue:@(500)];
        [definitions addObject:definition];

        definition = [[SCArgumentDefinition alloc] init];
        [definition setArgumentId:@"testFloat"];
        [definition setArgumentType:SCArgumentTypeKeyword];
        [definition setValueType:SCValueTypeFloat];
        [definition setShortKeyword:@"c"];
        [definition setLongKeyword:@"test-float"];
        [definition setMetaName:@"float"];
        [definitions addObject:definition];

        definition = [[SCArgumentDefinition alloc] init];
        [definition setArgumentId:@"testDecimal"];
        [definition setArgumentType:SCArgumentTypeKeyword];
        [definition setValueType:SCValueTypeDecimal];
        [definition setShortKeyword:@"d"];
        [definition setLongKeyword:@"test-decimal"];
        [definition setMetaName:@"decimal"];
        [definitions addObject:definition];

        definition = [[SCArgumentDefinition alloc] init];
        [definition setArgumentId:@"testString"];
        [definition setArgumentType:SCArgumentTypeKeyword];
        [definition setValueType:SCValueTypeString];
        [definition setShortKeyword:@"e"];
        [definition setLongKeyword:@"test-string"];
        [definition setMetaName:@"string"];
        [definitions addObject:definition];

        definition = [[SCArgumentDefinition alloc] init];
        [definition setArgumentId:@"testFile"];
        [definition setArgumentType:SCArgumentTypeKeyword];
        [definition setValueType:SCValueTypeFile];
        [definition setShortKeyword:@"f"];
        [definition setLongKeyword:@"test-file"];
        [definition setMetaName:@"file"];
        [definitions addObject:definition];

        definition = [[SCArgumentDefinition alloc] init];
        [definition setArgumentId:@"testPositional1"];
        [definition setArgumentType:SCArgumentTypePositional];
        [definition setValueType:SCValueTypeInteger];
        [definition setMetaName:@"positional-integer"];
        [definition setRequired:YES];
        [definitions addObject:definition];

        definition = [[SCArgumentDefinition alloc] init];
        [definition setArgumentId:@"testPositional2"];
        [definition setArgumentType:SCArgumentTypePositional];
        [definition setValueType:SCValueTypeFile];
        [definition setMetaName:@"positional-file"];
        [definitions addObject:definition];

        definition = [[SCArgumentDefinition alloc] init];
        [definition setArgumentId:@"testPositionalVariable"];
        [definition setArgumentType:SCArgumentTypePositional];
        [definition setVariableLength:YES];
        [definition setValueType:SCValueTypeString];
        [definition setMetaName:@"strings..."];
        [definitions addObject:definition];
        
        definition = [[SCArgumentDefinition alloc] init];
        [definition setArgumentId:@"testRequiredInteger"];
        [definition setArgumentType:SCArgumentTypeKeyword];
        [definition setValueType:SCValueTypeInteger];
        [definition setShortKeyword:@"g"];
        [definition setLongKeyword:@"test-integer-required"];
        [definition setMetaName:@"integer"];
        [definition setRequired:YES];
        [definitions addObject:definition];
        
        definition = [[SCArgumentDefinition alloc] init];
        [definition setArgumentId:@"showHelp"];
        [definition setArgumentType:SCArgumentTypeKeyword];
        [definition setShortKeyword:@"h"];
        [definition setLongKeyword:@"help"];
        [definition setValueType:SCValueTypeBoolean];
        [definitions addObject:definition];

        SCArgumentParser *parser = [[SCArgumentParser alloc] init];
        NSString *helpText =
        @"Usage: %@ [<options>] [<integer>] [<file>] [<string>...]\n"
        @"\n"
        @"Description:\n"
        @"  This is an example to display how to use SCArgumentParser. It is a simple\n"
        @"  library for defining and parsing command-line arguments.\n"
        @"\n"
        @"Options:\n"
        @"  -b <integer>, --test-integer=<integer>\n"
        @"                        A test integer for this application. I could define all of\n"
        @"                        the various options here, but it would be a little much for\n"
        @"                        a test application.\n"
        @"  -h, --help            Show this help message and exit.";
        helpText = [NSString stringWithFormat:helpText, [parser processName]];
        [parser setHelpText:helpText];
        [parser setArgumentDefinitions:definitions];

        NSDictionary *results;
        NSError *error;

        // Test required arguments.
        [parser setArguments:@[@"-e", @"foo"]];
        if ([parser parseArgumentsIntoResults:&results error:&error])
        {
            NSLog(@"Test required arguments failed. No required arguments passed.");
        }
        [parser setArguments:@[@"-g", @"5"]];
        if ([parser parseArgumentsIntoResults:&results error:&error])
        {
            NSLog(@"Test required arguments failed. Required positional argument not passed.");
        }
        [parser setArguments:@[@"7"]];
        if ([parser parseArgumentsIntoResults:&results error:&error])
        {
            NSLog(@"Test required arguments failed. Required keyword argument not passed.");
        }
        [parser setArguments:@[@"-g", @"5", @"7"]];
        if (![parser parseArgumentsIntoResults:&results error:&error])
        {
            NSLog(@"Test required arguments failed. All requirements passed. %@", error);
        }

        // Test parsing lots of arguments.
        [parser setArguments:@[@"-a", @"--test-float=3.14159", @"-d", @"5.25", @"--test-string=MyString", @"-f", @"SCArgumentParserExample/main.m", @"-g", @"17", @"42"]];
        if (![parser parseArgumentsIntoResults:&results error:&error])
        {
            NSLog(@"Test argument parsing failed. %@", error);
        }
        else
        {
            if (![results[@"testBoolean"] boolValue])
            {
                NSLog(@"Test argument parsing failed. testBoolean should be YES.");
            }
            if ([results[@"testInteger"] integerValue] != 500)
            {
                NSLog(@"Test argument parsing failed. testInteger should default to 500.");
            }
            if (fabsf([results[@"testFloat"] floatValue] - 3.14159) > FLT_EPSILON)
            {
                NSLog(@"Test argument parsing failed. testFloat should be to 3.14159.");
            }
            if (![results[@"testDecimal"] isEqualToNumber:[NSDecimalNumber decimalNumberWithString:@"5.25" locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]]])
            {
                NSLog(@"Test argument parsing failed. testDecimal should be to 5.25.");
            }
            if (![results[@"testString"] isEqualToString:@"MyString"])
            {
                NSLog(@"Test argument parsing failed. testString should be MyString.");
            }
            if (![[NSFileManager defaultManager] fileExistsAtPath:results[@"testFile"]])
            {
                NSLog(@"Test argument parsing failed. testFile should exist.");
            }
            if ([results[@"testRequiredInteger"] integerValue] != 17)
            {
                NSLog(@"Test argument parsing failed. testRequiredInteger should be 17.");
            }
            if ([results[@"testPositional1"] integerValue] != 42)
            {
                NSLog(@"Test argument parsing failed. testPositional1 should be 42.");
            }
        }

        // Test parsing variable arguments.
        [parser setArguments:@[@"-g", @"17", @"42", @"SCArgumentParserExample/main.m", @"a", @"b", @"c", @"d"]];
        if (![parser parseArgumentsIntoResults:&results error:&error])
        {
            NSLog(@"Test variable argument parsing failed. %@", error);
        }
        else
        {
            NSArray *array = results[@"testPositionalVariable"];
            if ([array count] != 4 || ![array[0] isEqualToString:@"a"] || ![array[1] isEqualToString:@"b"] || ![array[2] isEqualToString:@"c"] || ![array[3] isEqualToString:@"d"])
            {
                NSLog(@"Test variable argument parsing failed. Variable arguments not parsed as expected.");
            }
        }
    }

    return 0;
}
