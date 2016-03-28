package PEF::Prolog;

use strict;
use warnings;

use Module::Load;
use Attribute::Handlers;
use Sub::Name;
use Filter::Util::Call;
use Carp;

our $VERSION = '0.01';

my %imported_code;
my %imported_vars;
my $current_global_use;

sub import {
	my ($class, @imports) = @_;
	my @extra_vars;
	$current_global_use = '';
	for my $module (@imports) {
		if (exists $imported_vars{$module}) {
			push @extra_vars, @{$imported_vars{$module}};
			next;
		}
		load $module;
		my $prolog;
		my $imported_global_use;
		{
			no strict 'refs';
			no warnings 'once';
			$prolog              = *{$module . "::PROLOG"}{HASH};
			$imported_global_use = *{$module . "::GLOBAL_USE"}{SCALAR};
		}
		if ($imported_global_use && $$imported_global_use) {
			$current_global_use .= $$imported_global_use;
		}
		if ($prolog && %$prolog) {
			my %varset;
			for my $imp_key (keys %$prolog) {
				if ($prolog->{$imp_key}{vars} && @{$prolog->{$imp_key}{vars}}) {
					@varset{@{$prolog->{$imp_key}{vars}}} = undef;
				}
				if ($prolog->{$imp_key}{code}) {
					$imported_code{$imp_key}{code} = $prolog->{$imp_key}{code};
					$imported_code{$imp_key}{vars} = $prolog->{$imp_key}{vars};
					if ($prolog->{$imp_key}{external}) {
						$imported_code{$imp_key}{external} = $prolog->{$imp_key}{external};
					}
				}
			}
			$imported_vars{$module} = [keys %varset];
		} else {
			$imported_vars{$module} = [];
		}
		push @extra_vars, @{$imported_vars{$module}};
	}
	if (@extra_vars) {
		my %varset;
		@varset{@extra_vars} = undef;
		my $out_vars = join ";", map {"our $_"} keys %varset;
		my $done = 0;
		filter_add(
			sub {
				my ($status);
				$status = filter_read();
				$_      = "$current_global_use;$out_vars;$_" if not $done;
				$done   = 1;
				$status;
			}
		);
	}
}

sub UNIVERSAL::Prolog : ATTR(CODE, CHECK) {
	my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;
	my %attrs;
	my @attrs;
	$data = [$data] if not ref $data;
	for (my $i = 0; $i < @$data; $i++) {
		push @attrs, $data->[$i];
		if ($i < @$data - 1) {
			if (ref $data->[$i + 1]) {
				$attrs{$data->[$i]} = $data->[$i + 1];
				$i++;
			} else {
				$attrs{$data->[$i]} = undef;
			}
		}
	}
	my $internal_prolog = '';
	my $external_prolog = '';
	my %varset;
	for my $prolog (@attrs) {
		if (exists $imported_code{$prolog}) {
			my ($code, $external);
			if ($imported_code{$prolog}{vars} && @{$imported_code{$prolog}{vars}}) {
				@varset{@{$imported_code{$prolog}{vars}}} = undef;
			}
			if (ref $imported_code{$prolog}{code} eq 'CODE') {
				$code = $imported_code{$prolog}{code}->($attrs{$prolog}, $prolog, \%attrs) || '';
			} else {
				$code = $imported_code{$prolog}{code} || '';
			}
			if (ref $imported_code{$prolog}{external} eq 'CODE') {
				$external = $imported_code{$prolog}{external}->($attrs{$prolog}, $prolog, \%attrs) || '';
			} else {
				$external = $imported_code{$prolog}{external} || '';
			}
			$internal_prolog .= $code;
			$external_prolog .= $external;
		}
	}
	my $out_vars = join ";", map {"our $_"} keys %varset;
	my $gen_txt = join ";\n",
		(
		"package $package",
		$current_global_use, $external_prolog, $out_vars, "sub {\n$internal_prolog;\n&\$referent;\n}"
		);
	my $gen_sub = eval $gen_txt;
	croak "Exception $@ at filename $filename, line $linenum: $gen_txt" if $@;
	{
		no strict 'refs';
		no warnings 'redefine';
		my $orig_name = *{$symbol}{NAME};
		my $subname   = "_prolog_$orig_name";
		my @mtch      = map { s/\.pm$//; s|/|::|g; $_ } keys %INC;
		push @mtch, 'main';
		$gen_sub = subname $subname => $gen_sub;
		for my $expmod (@mtch) {
			if (*{$expmod . "::$orig_name"}{CODE} && *{$expmod . "::$orig_name"}{CODE} == $referent) {
				*{$expmod . "::$orig_name"} = $gen_sub;
			}
		}
	}
}
1;
