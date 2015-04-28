package Parser;
use strict;
use utf8;

use PPI;
use JSON::XS;

our $json_data = []; #解析結果リスト
our $line = 1;       #行数
our $class_name = "";

sub run {
    my ($self, @args) = @_;
    my $document = PPI::Document->new($args[0]);

    if (ref $document eq 'PPI::Document') {
        parser ($document);
    }
    my $output_json = JSON::XS->new->utf8(0)->encode ($json_data);
    print $output_json;

}

sub parser {
    my $doc = shift;

    if (exists $doc->{children}) {
        my @docs = $doc->children;
        for (my $i = 0; $i < scalar @docs; $i++) {
            my $q = $docs[$i];
            if (is_new_line($q)) {
                $line ++;
            }
            elsif (ref $q eq 'PPI::Statement::Variable') {
                # 変数定義の場合
                push_variable_data($q, get_variable_comment("", \@docs, $i));
            }
            elsif (ref $q eq 'PPI::Statement::Sub') {
                # 関数定義の場合
                push_function_data($q, get_function_comment("", \@docs, $i));
            }
            elsif (ref $q eq 'PPI::Statement::Package') {
                # クラス定義の場合
                push_class_data($q, get_variable_comment("", \@docs, $i));
            }
            parser($q);
        }
    }
}

# 行数++の判断
sub is_new_line {
    my $doc = shift;
    if (ref $doc eq 'PPI::Token::Whitespace' && $doc->content =~ /\n/) {
        # \nの場合、行数++
        return 1;
    }
    elsif (ref $doc eq 'PPI::Token::Comment' && $doc->content =~ m/\n$/) {
        # コメントの場合、\nがコメントメセッジに食われたから行数++
        return 1;
    }
    return 0;
}

# 変数(かクラス)のコメントを取る
# 定義と同じ行にあるコメント
sub get_variable_comment {
    my ($comment, $docs, $i) = @_;

    if (exists $docs->[$i + 1] && ref $docs->[$i + 1] eq 'PPI::Token::Whitespace' && $docs->[$i + 1]->content ne "\n" && exists $docs->[$i + 2] && ref $docs->[$i + 2] eq 'PPI::Token::Comment') {
        return $docs->[$i + 2]->content;
    }
}

# 関数のコメントを取る
# 関数の上のコメントを取る
sub get_function_comment {
    my ($comment, $docs, $i) = @_;

    if (exists $docs->[$i - 1]) {
        if (ref $docs->[$i - 1] eq 'PPI::Token::Comment') {
            return get_function_comment(clean_comment($docs->[$i - 1]->content) . $comment, $docs, $i - 1);
        }
        elsif (ref $docs->[$i - 1] eq 'PPI::Token::Whitespace' && $docs->[$i - 1]->content !~ /\n/) {
            return get_function_comment($comment, $docs, $i - 1);
        }
    }
    return $comment;
}

# 取ったコメントの最初の空白はいらない
sub clean_comment {
    my $comment = shift;
    $comment =~ s/^\s+//;
    return $comment;
}

# 変数のデーターをjson_dataに入れる
sub push_variable_data {
    my ($variable, $comment) = @_; 

    my $variable_symbols = $variable->find('PPI::Token::Symbol');
    if ($variable_symbols && scalar @$variable_symbols > 0 ) {
        push @$json_data, {
            type => "variable",
            name => $variable_symbols->[0]->content,
            line => $line,
            class_name => $class_name,
            comment => $comment,
        };
    }
}

# 関数のデーターをjson_dataに入れる
sub push_function_data {
    my ($function, $comment) = @_;

    my $function_words = $function->find('PPI::Token::Word');
    if ( $function_words && scalar @$function_words > 1) {
        my $function_lines = {
            start_line => $line,
            name_line =>  $line,
            end_line => $line,
            name_line_flag => 0,
            name_line_complete => 1,
        };
        paser_function($function, $function_lines);

        push @$json_data, {
            type => "function",
            name => $function_words->[1]->content,
            line => $function_lines->{name_line},
            start_line => $function_lines->{start_line},
            end_line => $function_lines->{end_line},
            class_name => $class_name,
            comment => $comment,
        };
    }
}

# クラスのデーターをjson_dataに入れる
sub push_class_data {
    my ($class, $comment) = @_;

    my $package_words = $class->find('PPI::Token::Word');
    if ($package_words && scalar @$package_words > 1) {
        $class_name = $package_words->[1]->content;
        push @$json_data, {
            type => "class",
            name => $package_words->[1]->content,
            line => $line,
            class_name => "",
            comment => $comment,
        };
    }

}

# 関数の識別子名行と終わり行を取る
sub paser_function{
    my ($doc, $function_lines) = @_;

    if (exists $doc->{children}) {
        my @docs = $doc->children;
        for (my $i = 0; $i < scalar @docs; $i++) {
            my $q = $docs[$i];
            if (is_new_line($q)) {
                $function_lines->{end_line} ++;
            }
            elsif ($function_lines->{name_line_complete} && ref $q eq 'PPI::Token::Word') {
                if ($function_lines->{name_line_flag}) {
                    $function_lines->{name_line} = $function_lines->{end_line};
                    $function_lines->{name_line_complete} = 0;
                }
                else {
                    $function_lines->{name_line_flag} = 1;
                }
            }
            paser_function($q, $function_lines);
        }
    }
}
1;
