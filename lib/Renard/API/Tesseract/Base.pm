use Renard::Incunabula::Common::Setup;
package Renard::API::Tesseract::Base;
# ABSTRACT: Base API

use Inline with => qw(Renard::API::Tesseract::Inline);
use Renard::API::Tesseract::Base::Inline CPP => 'DATA';

1;
=head1 SEE ALSO

L<Repository information|http://project-renard.github.io/doc/development/repo/p5-Renard-API-Tesseract/>

=cut
__DATA__
__CPP__

using namespace tesseract;
typedef TessBaseAPI Renard__API__Tesseract__Base;

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
