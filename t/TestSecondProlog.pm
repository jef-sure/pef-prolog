package TestSecondProlog;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use PEF::Prolog qw(TestProlog);
use base 'Exporter';

our @EXPORT = qw(get_product_description);

sub get_product_description : Prolog(get_product) {
	$product->{description};
}

1;
