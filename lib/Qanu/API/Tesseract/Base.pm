use Renard::Incunabula::Common::Setup;
package Qanu::API::Tesseract::Base;
# ABSTRACT: Base API

use Inline with => qw(Qanu::API::Tesseract::Inline);
use Qanu::API::Tesseract::Base::Inline CPP => 'DATA';

use File::Spec;
use File::Basename;

classmethod tessdata_prefix() {
	my $TESSDATA_PREFIX;

	if( exists $ENV{MSYSTEM} ) {
		# q|C:\msys64\mingw64\share\tessdata|;
		$TESSDATA_PREFIX = File::Spec->catfile(dirname($^X), qw(.. share tessdata));
	}

	$TESSDATA_PREFIX ||= undef;

	return $TESSDATA_PREFIX;
}

classmethod new() {
	Qanu::API::Tesseract::Base->_new( $class->tessdata_prefix );
}

1;
=head1 SEE ALSO



=cut
__DATA__
__CPP__

using namespace tesseract;
typedef TessBaseAPI Qanu__API__Tesseract__Base;

TessBaseAPI* _new(char* CLASS, SV* tessdata_path_sv) {
	// If undef, use NULL to use default TESSDATA_PREFIX
	char* tessdata_path = SvOK(tessdata_path_sv) ? SvPV_nolen(tessdata_path_sv) : NULL;

	// Tesseract initialisation requires "C" locale.
	// See:
	//   - <https://github.com/tesseract-ocr/tesseract/pull/1649>,
	//   - <https://github.com/tesseract-ocr/tesseract/issues/1250>,
	//   - <https://github.com/tesseract-ocr/tesseract/issues/1670>.
	setlocale(LC_ALL, "C");

	TessBaseAPI* api = new tesseract::TessBaseAPI();

	return api;
}

void _destroy(TessBaseAPI* self) {
	self->End();
}
