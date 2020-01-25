#!/usr/bin/env perl

use Test::Most tests => 1;

use Renard::Incunabula::Common::Setup;
use Renard::API::Tesseract::Base;

subtest "Test" => fun() {
	my $api = Renard::API::Tesseract::Base->new;
	isa_ok $api, 'Renard::API::Tesseract::Base';
	pass;
};

done_testing;
