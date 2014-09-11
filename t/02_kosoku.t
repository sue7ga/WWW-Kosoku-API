use strict;
use warnings;
use Test::More;
use WWW::Kosoku::API;

my $kosoku = WWW::Kosoku::API->new(f => '渋谷',t => '浜松',c => '普通車');

my $summary_list = $kosoku->get_all_summary();

use Data::Dumper;

print Dumper $summary_list;