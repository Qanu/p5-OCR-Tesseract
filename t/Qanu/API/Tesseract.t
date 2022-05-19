#!/usr/bin/env perl

use Test::Most tests => 1;

use Renard::Incunabula::Common::Setup;
use OCR::Tesseract::Base;

subtest "Test" => fun() {
	my $api = OCR::Tesseract::Base->new;
	isa_ok $api, 'OCR::Tesseract::Base';
	pass;
};

done_testing;
