use strict;
use warnings;
use Test::More;
use utf8;
use WWW::Kosoku::API;

my $kosoku = WWW::Kosoku::API->new(f => '渋谷',t => '浜松',c => '普通車');

use Data::Dumper;
{
 package Data::Dumper;
 sub qquote {return shift;}
}
$Data::Dumper::Useperl = 1;

is($kosoku->response->{CarType},'普通車');
is($kosoku->response->{SortBy},'距離');
is($kosoku->response->{Status},'End');

subtest 'Routes' => sub{
 my $route = $kosoku->response->{Routes}->{Route};
 is($route->[2]->{RouteNo},2);
};

subtest 'Section' => sub{
 my $route = $kosoku->response->{Routes}->{Route};
 my $subsection = $route->[1]->{Details}->{Section}->[0]->{SubSections}->{SubSection};
 is_deeply $subsection,[
                            {
                              'Length' => '3.8',
                              'Time' => 4,
                              'Road' => '首都高速３号渋谷線',
                              'To' => '谷町ＪＣＴ',
                              'From' => '渋谷'
                            },
                            {
                              'Length' => '3.6',
                              'Time' => 5,
                              'Road' => '首都高速都心環状線',
                              'To' => '浜崎橋ＪＣＴ',
                              'From' => '谷町ＪＣＴ'
                            },
                            {
                              'Length' => '0.6',
                              'Time' => 1,
                              'Road' => '首都高速１号羽田線',
                              'To' => '芝浦ＪＣＴ',
                              'From' => '浜崎橋ＪＣＴ'
                            },
                            {
                              'Length' => 5,
                              'Time' => 6,
                              'Road' => '首都高速１１号台場線',
                              'To' => '有明ＪＣＴ',
                              'From' => '芝浦ＪＣＴ'
                            },
                            {
                              'Length' => '30.3',
                              'Time' => 24,
                              'Road' => '首都高速湾岸線',
                              'To' => '本牧ＪＣＴ',
                              'From' => '有明ＪＣＴ'
                            },
                            {
                              'Length' => '9.9',
                              'Time' => 12,
                              'Road' => '首都高速神奈川３号狩場線',
                              'To' => '狩場',
                              'From' => '本牧ＪＣＴ'
                            }
                          ];
};

subtest 'Summary' => sub{
   is($kosoku->response->{Routes}->{Route}->[1]->{Summary}->{TotalLength},279.2);
   is($kosoku->response->{Routes}->{Route}->[1]->{Summary}->{TotalToll},6000);
   is($kosoku->response->{Routes}->{Route}->[1]->{Summary}->{TotalTime},200);
};

subtest "Tolls" => sub{
  my $route = $kosoku->response;  
  is($route->{Routes}->{Route}->[0]->{Details}->{No},3);
  is($route->{Routes}->{Route}->[0]->{Details}->{Section}->[0]->{Length},38.1);
  is($route->{Routes}->{Route}->[0]->{Details}->{Section}->[0]->{From},'渋谷');
  is($route->{Routes}->{Route}->[0]->{Details}->{Section}->[0]->{To},'保土ヶ谷');
  is($route->{Routes}->{Route}->[0]->{Details}->{Section}->[0]->{Order},0);
  is($route->{Routes}->{Route}->[0]->{Details}->{Section}->[0]->{Time},41);
  is($route->{Routes}->{Route}->[0]->{Details}->{Section}->[0]->{Tolls}->{No},2);
  is_deeply $route->{Routes}->{Route}->[0]->{Details}->{Section}->[0]->{Tolls}->{Toll},[
                                     '930円 通常料金',
                                     '930円 ETC料金'  
  ];
  is_deeply $route->{Routes}->{Route}->[0]->{Details}->{Section}->[0]->{SubSections}->{SubSection}->[0],{            
            'Length' => '3.8',
            'Time' => 4,
            'Road' => '首都高速３号渋谷線',
            'To' => '谷町ＪＣＴ',
            'From' => '渋谷'
     };
};



done_testing;

