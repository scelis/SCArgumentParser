# SCArgumentParser

SCArgumentParser is an Objective-C library for parsing command-line arguments and options.

This project is still quite basic and could use some additional work put into handling various error cases. For example, it could warn the user if they enter an invalid keyword or if they have too many positional arguments. In addition, it could warn the user if they enter a string for a keyword argument that expects an integer.

## Usage

To include SCArgumentParser in your applications, clone the SCArgumentParser repository and include all of the SCArgumentParser source files in your project.

    $ git clone git://github.com/scelis/SCArgumentParser.git

See the included Xcode project (specifically the [`main.m`][main.m] source file) for a detailed example of how to use SCArgumentParser.

[main.m]: https://github.com/scelis/SCArgumentParser/Example/SCArgumentParserExample/main.m
