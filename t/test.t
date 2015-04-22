use strict;
use warnings;
use utf8;
use Test::More;
use Data::Dumper;

use lib '../lib';
use Parser;

my $test_file1_src = "test_file/test_file1";
my $test_variable_src = "test_file/test_variable";
my $test_function_src = "test_file/test_function";

my $test_file1_doc = PPI::Document->new('t/test_file/test_file1');
my $test_variable_doc = PPI::Document->new('t/test_file/test_variable');
my $test_function_doc = PPI::Document->new('t/test_file/test_function');

Parser::parser($test_file1_doc);

subtest 'test_files_run' => sub {
    ok ( Parser->run($test_file1_src), 'test_file1 ok');
    ok ( Parser->run($test_variable_src), 'test_variable ok');
    ok ( Parser->run($test_function_src), 'test_function ok');
};

subtest 'variable_test' => sub {
    my $variables = $test_variable_doc->find('PPI::Statement::Variable');
    is (ref $variables, "ARRAY", "get variables");
    for (my $i = 0; $i < scalar @$variables; $i++) {
        ok ( Parser::push_variable_data($variables->[$i]), "variable $i ok");
    }
};

subtest 'function_test' => sub {
    my $functions = $test_function_doc->find('PPI::Statement::Sub');
    is (ref $functions, "ARRAY", "get functions");
    for (my $i = 0; $i < scalar @$functions; $i++) {
        ok ( Parser::push_function_data($functions->[$i]), "function $i ok");
    }
};

subtest 'is_new_line' => sub {
    my $whitespaces = $test_file1_doc->find('PPI::Token::Whitespace');
    is (ref $whitespaces, "ARRAY", "get whitespaces of test_file1");
    for (my $i = 0; $i < scalar @$whitespaces; $i++) {
        if ($whitespaces->[$i]->content =~ /\n/) {
            is (Parser::is_new_line($whitespaces->[$i]), 1, "whitespaces $i of test_file1 ok");
        }
        else {
            is (Parser::is_new_line($whitespaces->[$i]), 0, "whitespaces $i of test_file1 ok");
        }
    }

    $whitespaces = $test_variable_doc->find('PPI::Token::Whitespace');
    is (ref $whitespaces, "ARRAY", "get whitespaces of test_variable");
    for (my $i = 0; $i < scalar @$whitespaces; $i++) {
        if ($whitespaces->[$i]->content =~ /\n/) {
            is (Parser::is_new_line($whitespaces->[$i]), 1, "whitespaces $i of test_variable ok");
        }
        else {
            is (Parser::is_new_line($whitespaces->[$i]), 0, "whitespaces $i of test_variable ok");
        }
    }


    $whitespaces = $test_function_doc->find('PPI::Token::Whitespace');
    is (ref $whitespaces, "ARRAY", "get whitespaces of test_function");
    for (my $i = 0; $i < scalar @$whitespaces; $i++) {
        if ($whitespaces->[$i]->content =~ /\n/) {
            is (Parser::is_new_line($whitespaces->[$i]), 1, "whitespaces $i of test_function ok");
        }
        else {
            is (Parser::is_new_line($whitespaces->[$i]), 0, "whitespaces $i of test_function ok");
        }
    }

    my $comments = $test_file1_doc->find('PPI::Token::Comment');
    is (ref $whitespaces, "ARRAY", "get comment of test_file1");
    for (my $i = 0; $i < scalar @$comments; $i++) {
        if ($comments->[$i]->content =~ m/\n$/) {
            is (Parser::is_new_line($comments->[$i]), 1, "comments $i of test_file1 ok");
        }
        else {
            is (Parser::is_new_line($comments->[$i]), 0, "comments $i of test_file1 ok");
        }
    }

    $comments = $test_variable_doc->find('PPI::Token::Comment');
    is (ref $whitespaces, "ARRAY", "get comment of test_variable");
    for (my $i = 0; $i < scalar @$comments; $i++) {
        if ($comments->[$i]->content =~ m/\n$/) {
            is (Parser::is_new_line($comments->[$i]), 1, "comments $i of test_variable ok");
        }
        else {
            is (Parser::is_new_line($comments->[$i]), 0, "comments $i of test_variable ok");
        }
    }

    $comments = $test_function_doc->find('PPI::Token::Comment');
    is (ref $whitespaces, "ARRAY", "get comment of test_function");
    for (my $i = 0; $i < scalar @$comments; $i++) {
        if ($comments->[$i]->content =~ m/\n$/) {
            is (Parser::is_new_line($comments->[$i]), 1, "comments $i of test_function ok");
        }
        else {
            is (Parser::is_new_line($comments->[$i]), 0, "comments $i of test_function ok");
        }
    }

};

done_testing;
