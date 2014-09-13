use strict;
use warnings;
use Test::More;
use utf8;
use WWW::Kosoku::API;

my $kosoku = WWW::Kosoku::API->new(f => '渋谷',t => '浜松',c => '普通車');

is($kosoku->{c},'普通車');

done_testing;