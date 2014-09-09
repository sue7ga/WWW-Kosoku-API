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

our $VERSION = "0.01";

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

sub get_section{
 my $self = shift;
 my $ref = $self->response;
 my @Details = @{$ref->{Routes}->{Route}->[1]->{Details}->{Section}};
 return @Details;
}

1;

__END__

=encoding utf-8

=head1 NAME

WWW::Kosoku::API - It's new $module

=head1 SYNOPSIS

    use WWW::Kosoku::API;

=head1 DESCRIPTION

WWW::Kosoku::API is ...

=head1 LICENSE

Copyright (C) sue7ga.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

sue7ga E<lt>sue77ga@gmail.comE<gt>

=cut

