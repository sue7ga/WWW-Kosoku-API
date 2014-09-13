package WWW::Kosoku::API;
use 5.008005;
use strict;
use warnings;
use utf8;
use Mouse;
use URI;
use Furl;
use XML::Simple;
use Carp;

our $VERSION = "0.04";

use constant BASE_URL => 'http://kosoku.jp/api/route.php?';

has 'f' => (is => 'rw', isa => 'Str',required => 1);
has 't' => (is => 'rw', isa => 'Str',required => 1);
has 'c' => (is => 'rw', isa => 'Str',required => 1,default => '普通車');
has 's' => (is => 'rw', isa => 'Str');
has 'sortBy' => (is => 'rw',isa => 'Str',default => '距離');

has furl => (
  is => 'rw',
 isa => 'Furl',
 default => sub{
   my $furl = Furl->new(
     agent => 'WWW::Kosoku::API(Perl)',
     timeout => 10,
   );
    $furl;
 },
);

sub response{
 my $self = shift;
 my $url = URI->new(BASE_URL);
 $url->query_form(f => $self->f,t => $self->t,c => $self->c);
 my $response = $self->furl->get($url);
 my $ref = eval{
   my $xs = new XML::Simple();
   $xs->XMLin($response->content);
 };
 if($@){
   croak("Oh! faild reading XML");
 }
 return $ref;
}

use Data::Dumper;

#routenumber and subsections
sub get_subsection{
 my $self = shift;
 my $subsection = [];
 my $ref = $self->response;
 for my $route(@{$ref->{Routes}->{Route}}){
    for my $sec(@{$route->{Details}->{Section}}){
       push @{$subsection},{$route->{RouteNo},$sec->{SubSections}->{SubSection}};
    }
 }
  return $subsection;
}

# section_count in routenumber
sub get_section_no_by_routenumber{
 my ($self,$routenumber) = @_;
 my $ref = $self->response;
 return $ref->{Routes}->{Route}->[$routenumber]->{Details}->{No};
}

sub get_section_info_by_routenumber_sectionnumber{
 my($self,$routenumber,$sectionno) = @_;
 if($routenumber < 0 ||  $self->get_route_count <= $routenumber){
   croak("no routenumber:$routenumber");
 }
 if($sectionno < 0 || $sectionno >= $self->get_section_no_by_routenumber){
   croak("no section_no_number:$sectionno");
 }
 my $ref = $self->response;
 return $ref->{Routes}->{Route}->[$routenumber]->{Details}->{Section}->[$sectionno];
}

#get subsection by routenumber and sectionnumber
sub get_subsection_by_routenumber_and_sectionnumber{
 my($self,$routenumber,$sectionnumber) = @_;
 if($routenumber < 0 ||  $self->get_route_count <= $routenumber){
   croak("no routenumber:$routenumber");
 }
 if($sectionnumber < 0 || $sectionnumber >= $self->get_section_no_by_routenumber){
   croak("no section_no_number:$sectionnumber");
 }
 my $ref = $self->response;
 return $ref->{Routes}->{Route}->[$routenumber]->{Details}->{Section}->[$sectionnumber]->{SubSections}->{SubSection};
}

#get section info by routenumber
sub get_section_by_routenumber{
 my($self,$routenumber) = @_;
 if($routenumber < 0 ||  $self->get_route_count <= $routenumber){
   croak("no routenumber:$routenumber");
 }
 my $ref = $self->response;
 return $ref->{Routes}->{Route}->[$routenumber]->{Details}->{Section};
}

#get section toll by routenumber and sectionnumber
sub get_section_tolls_by_routenumber_and_sectionnumber{
 my($self,$routenumber,$sectionnumber) = @_;
 my $section_info = $self->get_section_info_by_routenumber_sectionnumber($routenumber,$sectionnumber);
 return $section_info->{Tolls}->{Toll};
}

#get time and toll and legnth by routenumber
sub get_summary_by_routenumber{
 my($self,$routenumber) = @_;
 my $ref = $self->response;
 return $ref->{Routes}->{Route}->[$routenumber]->{Summary};
}

sub get_all_summary{
 my $self = shift;
 my $summary_list = [];
 for my $count(0..$self->get_route_count-1){
    push @$summary_list,$self->get_summary_by_routenumber($count);
 }
 return $summary_list;
}

#get route count
sub get_route_count{
 my $self = shift;
 my $ref = $self->response;
 scalar @{$ref->{Routes}->{Route}};
}

# get subsectionsinfo by routenumber
sub get_subsections_by_routenumber{
 my ($self,$routenumber) = @_;
 if($routenumber < 0 || $routenumber >= $self->get_route_count){
   croak("no route number:$routenumber");
 }
 my $subsection = $self->get_subsection;
 my $sub_list = [];
 for my $sub (@{$subsection}){
  if(defined $sub->{$routenumber}){
   if(ref $sub->{$routenumber} eq 'ARRAY'){
     for my $subsec(@{$sub->{$routenumber}}){
       push @$sub_list,$subsec;
     }
   }elsif(ref $sub->{$routenumber} eq 'HASH'){
       push @$sub_list,$sub->{$routenumber};
   }
  }
 }
 return $sub_list;
}

sub get_subsections_and_sectioncount_by_routenumber{
 my($self,$routenumber) = @_;
 my $subsection = [];
 my $subsection_info = $self->get_subsection;
 my $sectioncount = 0;
 for my $key(@{$subsection_info}){
   if(defined $key->{$routenumber}){
     if(ref $key->{$routenumber} eq 'ARRAY'){
      push @$subsection,@{$key->{$routenumber}};
    }elsif(ref $key->{$routenumber} eq 'HASH'){
      push @$subsection,$key->{$routenumber};
    }
    $sectioncount++;
   }
 }
 return $sectioncount;
}

1;


__END__

=encoding utf-8

=head1 NAME

WWW::Kosoku::API - Kosoku WebService API

=head1 SYNOPSIS
    use WWW::Kosoku::API;

    my $kosoku = WWW::Kosoku::API->new(f => '渋谷',t => '浜松',c => '普通車');

    print $kosoku->{c} #=> 普通車
    print $kosoku->get_route_count #=> 20

    for my $subsection(@{$kosoku->get_subsection_by_routenumber_and_sectionnumber(1,0)}){
         print $subsection->{Length};
         print $subsection->{Time};
         print $subsection->{Road};
         print $subsection->{To};
         print $subsection->{From}; 
    }

=head1 DESCRIPTION

WWW::Kosoku::API is Kosoku WebService API.

=head1 LICENSE

Copyright (C) sue7ga.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

sue7ga E<lt>sue77ga@gmail.comE<gt>

=cut

