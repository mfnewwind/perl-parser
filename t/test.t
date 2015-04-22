use strict;
use warnings;
use utf8;
use Test::More;
#use Test::Exception;

use lib '../lib';
use Parser;

subtest 'basic' => sub {
    lives_ok {
        Parser->run("test_file/test_file1");
    }
};

done_testing;
