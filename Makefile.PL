use ExtUtils::MakeMaker;
WriteMakefile(
	NAME             => "PEF::Prolog",
	AUTHOR           => "Pef Secure",
	VERSION          => "0.01",
	INSTALLDIRS      => 'site',
	LICENSE          => "artistic_2",
	MIN_PERL_VERSION => "5.014000",
	META_MERGE       => {"meta-spec" => {version => 2}},
	PREREQ_PM     => {'Sub::Name'  => 0},
	TEST_REQUIRES => {'Test::More' => 0},
	test          => {TESTS        => "t/*.t"},
	dist          => {
		DIST_DEFAULT => 'all tardist',
		COMPRESS     => 'gzip -vf',
		SUFFIX       => '.gz',
	},
	clean     => {FILES => '*~'},
	realclean => {FILES => '*~'},
);
