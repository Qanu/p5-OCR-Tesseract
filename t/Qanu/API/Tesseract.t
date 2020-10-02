#!/usr/bin/env perl

use Test::Most tests => 1;

use Renard::Incunabula::Common::Setup;
use Qanu::API::Tesseract::Base;

subtest "Test" => fun() {
	my $api = Qanu::API::Tesseract::Base->new;
	isa_ok $api, 'Qanu::API::Tesseract::Base';
	pass;
};

done_testing;
