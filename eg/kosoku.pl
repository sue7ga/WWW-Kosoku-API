use strict;
use warnings;
use Carp;
use utf8;
use File::Spec;
use File::Basename 'dirname';
use lib (
    File::Spec->catdir(dirname(__FILE__),qw/.. lib/),
);
use Mojolicious::Lite;
use WWW::Kosoku::API;
use Data::Dumper;

get '/' => 'index';

post '/create' => sub{
   my $self = shift;
 
   my $params = $self->req->body_params->to_hash;
   my $from = $params->{from} ||= "hoge";
   my $to   = $params->{to} ||= "foo";

   my $kosoku = WWW::Kosoku::API->new(f => $from,t => $to,c => '普通車');
   my @details =  $kosoku->get_section;
   
   
   
   $self->render(text => "@details");
};

app->start;

__DATA__

@@ index.html.ep
<html>
  <body>
    <form method="post" action="<%= url_for('create')%>">
      From:<input type="text" name="from"><br>  
      To:<input type="text" name="to"><br>  
      <input type="submit" value="Sumit">
    </form>
  </body>
</html>
