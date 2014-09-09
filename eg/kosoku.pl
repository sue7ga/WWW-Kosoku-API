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

my $kosoku = WWW::Kosoku::API->new(f => '渋谷',t => '浜松',c => '普通車');

use Data::Dumper;

my @subsection = $kosoku->get_section;

for my $section(@subsection){
  my $subsection = $section->{SubSections}->{SubSection};
  if(ref $subsection  eq 'ARRAY'){
     for my $sub(@{$subsection}){
         print $sub->{From},"->",$sub->{To},"\n";
     }
  }elsif(ref $subsection eq 'HASH'){
         print $subsection->{From},"->",$subsection->{To},"\n";
  }
}


