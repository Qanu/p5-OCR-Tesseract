#!/usr/bin/env perl

use Test::Most;

use strict;
use warnings;
use Module::Load;
use Cwd 'abs_path';

use Env qw($TESSDATA_PREFIX);

use_ok('Renard::API::Tesseract::Inline');
use_ok('Renard::API::Tesseract::Base');

SKIP: {
	eval { load 'Inline::CPP' } or do {
		my $error = $@;
		skip "Inline::CPP not installed", 1 if $error;
	};

	Inline->import( with => qw(Renard::API::Tesseract::Inline) );

	$TESSDATA_PREFIX = Renard::API::Tesseract::Base->tessdata_prefix;

	subtest 'Retrieve a constant' => sub {
		Inline->bind( CPP => q|
			char* get_tess_version() {
				return TESSERACT_VERSION_STR;
			}
		|, ENABLE => AUTOWRAP => );

		# three numerical parts: major, minor, micro
		like( get_tess_version(),
			qr/^
				(?<major> \d+) \.
				(?<minor> \d+) \.
				(?<micro> \d+)
			$/x, "Got version @{[ get_tess_version() ]}");
	};

	subtest 'Initialise Tesseract' => sub {
		Inline->bind( CPP => q|
			#include <locale.h>

			int tess_init(SV* tessdata_path_sv) {
				// If undef, use NULL to use default TESSDATA_PREFIX
				char* tessdata_path = SvOK(tessdata_path_sv) ? SvPV_nolen(tessdata_path_sv) : NULL;

				// Tesseract initialisation requires "C" locale.
				// See:
				//   - <https://github.com/tesseract-ocr/tesseract/pull/1649>,
				//   - <https://github.com/tesseract-ocr/tesseract/issues/1250>,
				//   - <https://github.com/tesseract-ocr/tesseract/issues/1670>.
				setlocale(LC_ALL, "C");

				tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
				// Initialize tesseract-ocr with English, without specifying tessdata path
				if (api->Init(tessdata_path, "eng")) {
					fprintf(stderr, "Could not initialize tesseract.\n");
					api->End();
					return 0;
				}

				api->End();

				return 1;
			}
		|, ENABLE => AUTOWRAP => );

		{
			no locale;
			ok( tess_init($TESSDATA_PREFIX), 'Tesseract intialised');;
		}
	};

}

done_testing;
