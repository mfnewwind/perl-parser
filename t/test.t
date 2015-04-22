use strict;
use warnings;
use utf8;
use Test::More;

use lib '../lib';
use Parser;

my $test_file1_src = "test_file/test_file1";
my $test_variable_src = "test_file/test_variable";
my $test_function_src = "test_file/test_function";

subtest 'basic' => sub {
    ok ( Parser->run($test_file1_src), 'test_file1 ok');
    ok ( Parser->run($test_variable_src), 'test_variable ok');
    ok ( Parser->run($test_function_src), 'test_function ok');
};

done_testing;
