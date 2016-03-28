use FindBin qw($Bin);
use lib "$Bin/../lib", $Bin;
use PEF::Prolog qw(TestProlog);
use TestSecondProlog;
use Test::More;

use strict;
use warnings;

sub get_client_fullname : Prolog(get_client) {
	"$_[0]: $client->{fullname}";
}

sub get_client_login : Prolog(get_client) {
	$client->{user};
}

sub get_product_title : Prolog(get_product) {
	$product->{title};
}

is(get_client_fullname("full name"), "full name: U Ser");
is(get_client_login(),               "logged_user");
is(get_product_title(),              "Galaxy");
is(get_product_description(),        "Galaxy is your friend");

done_testing();
