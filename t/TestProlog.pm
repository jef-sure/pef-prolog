package TestProlog;
use strict;
use warnings;

our %PROLOG = (
	get_client => {
		vars => [qw($client)],
		code => <<EOC
	local \$client = {id => 1, user => "logged_user", fullname => "U Ser"};
EOC
	},
	get_product => {
		vars => [qw($product)],
		code => <<EOC
	local \$product = {id => 2, title => "Galaxy", description => "Galaxy is your friend"};
EOC
	}
);

our $GLOBAL_USE = 'use TestProlog;';

1;
