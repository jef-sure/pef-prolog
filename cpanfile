requires 'Sub::Name';
requires 'perl', 'v5.14.0';

on configure => sub {
    requires 'ExtUtils::MakeMaker';
};

on test => sub {
    requires 'Test::More';
};
