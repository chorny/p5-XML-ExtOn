use Test::More qw( no_plan);
use strict;
use warnings;

BEGIN {
    use_ok 'XML::Handler::ExtOn';
    use_ok 'XML::Filter::SAX1toSAX2';
    use_ok 'XML::Parser::PerlSAX';
    use_ok 'XML::SAX::Writer';
}
my $str1;
my $w1          = XML::SAX::Writer->new( Output         => \$str1 );
my $psax_filter = MyHandler->new( Handler               => $w1 );
my $sax2_filter = XML::Filter::SAX1toSAX2->new( Handler => $psax_filter );
my $parser      = XML::Parser::PerlSAX->new( Handler    => $sax2_filter );
my $xml         = &return_xml();
my $result = $parser->parse( Source => { String => "$xml" } );
diag $str1;
exit;

sub return_xml {
    return <<EOT;
<?xml version="1.0"?>
<Document xmlns="http://test.com/defaultns" xmlns:nodef='http://zag.ru' xmlns:xlink='http://www.w3.org/1999/xlink'>
    <nodef:p xlink:xtest="1" attr="1"><a href="sdsd">TTT<pe>Ooee</pe></a>test</nodef:p>
    <p defaulttest="1" xlink:attr="1" xlink:attr2="1">test</p>
</Document>
EOT
}

package MyHandler;
use Data::Dumper;
use strict;
use warnings;
use XML::Filter::SAX1toSAX2;
use XML::Parser::PerlSAX;
use base 'XML::Handler::ExtOn';

sub on_start_element {
    my ( $self, $elem ) = @_;

    #    warn "defult uri for :". $elem->local_name. " = ". $elem->default_uri;
    if ( $elem->local_name eq 'p' ) {
        $elem->add_namespace( ''    => "http://localhost/doc_com" );
        $elem->add_namespace( 'odd' => 'http://ofddd.com/ns' );
        my $odd = $elem->attrs_by_prefix('odd');
        %$odd = ( odd1 => 1, odd2 => 2 );
    }
    if ( $elem->local_name eq 'a' ) {
#        $elem->skip_content->delete_element;
#        $elem->skip_content;
        $elem->delete_element;
    }
    return $elem;
}

sub on_end_element {
    my $self = shift;
    my ( $elem, $data ) = @_;
#    warn " End Element : " . Dumper($data) . " : " . $elem->skip_content;
    if ( $elem->is_skip_content  && $elem->is_delete_element) {
       my $parser = $self->mk_from_xml( "<OOO>TEST</OOO>");#->parse;
        warn '$parser:'.$parser;
#    $parser->parse;
    }

#    warn "End Element:" .Dumper([$elem->set_prefix,$elem->set_ns_uri]);#to_sax2);
#    warn "End Element:data" .Dumper($data);
#    warn "End Element:ns" .Dumper($elem->ns->get_map);
#    warn "End Element:" . Dumper($data, $elem);
}

sub on_characters {
    my $self = shift;
    my ( $elem, $str ) = @_;
    $elem->{__chars} .= $str;
    return $str;
}

