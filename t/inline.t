#!/usr/bin/env perl

use Test::Most;

use Test::RequiresInternet;
use Path::Tiny;
use LWP::UserAgent;
use LWP::Protocol::https;

use strict;
use warnings;
use Module::Load;
use Cwd 'abs_path';

use Env qw($TESSDATA_PREFIX);

use_ok('OCR::Tesseract::Inline');
use_ok('OCR::Tesseract::Base');

SKIP: {
	eval { load 'Inline::CPP' } or do {
		my $error = $@;
		skip "Inline::CPP not installed", 1 if $error;
	};

	Inline->import( with => qw(Alien::Leptonica OCR::Tesseract::Inline) );

	$TESSDATA_PREFIX = OCR::Tesseract::Base->tessdata_prefix;

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


	subtest 'Tesseract: phototest.tif' => sub {
		Inline->bind( CPP => q|
			#include <locale.h>

			char* read_text(SV* tessdata_path_sv, char* file) {
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

				Pix *image = pixRead(file);
				api->SetImage( image );
				char* output = api->GetUTF8Text();

				api->End();
				pixDestroy(&image);

				return output;
			}
		|, ENABLE => AUTOWRAP => );

		{
			no locale;
			my %data = (
				image => "https://github.com/tesseract-ocr/test/blob/master/testing/phototest.tif?raw=true",
				text  => "https://github.com/tesseract-ocr/test/raw/master/testing/phototest.txt",
			);

			my $image_path = Path::Tiny->tempfile( SUFFIX => '.tif' );

			my $ua = LWP::UserAgent->new;
			$image_path->spew_raw( $ua->get( $data{image} )->decoded_content );
			my $expected_text = $ua->get( $data{text} )->decoded_content;

			my $text = read_text($TESSDATA_PREFIX, "$image_path");

			# Remove trailing newlines
			{ local $/ = ''; chomp( $text, $expected_text ); }

			is $text, $expected_text, 'OCR text matches';
		}
	};
}

done_testing;
