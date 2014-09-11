use strict;
use warnings;
use Carp;
use utf8;
use File::Spec;
use File::Basename 'dirname';
use lib (
    File::Spec->catdir(dirname(__FILE__),qw/.. lib/),
);
use WWW::Kosoku::API;
use Data::Dumper;
{
 package Data::Dumper;
 sub qquote {return shift;}
}
$Data::Dumper::Useperl = 1;

my $kosoku = WWW::Kosoku::API->new(f => '渋谷', t => '浜松', c => '普通車');

my $subsections = $kosoku->get_subsections_by_routenumber(10);

print Dumper $subsections;
