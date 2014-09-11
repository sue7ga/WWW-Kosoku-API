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

