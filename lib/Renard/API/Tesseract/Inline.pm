use Modern::Perl;
package Renard::API::Tesseract::Inline;
# ABSTRACT: Provide Inline configuration for Tesseract

use ExtUtils::PkgConfig;

use constant PKG_CONFIG => 'tesseract';

=method Inline

Provides C<Inline> 'with' functionality for the Tesseract OCR library.

=cut
sub Inline {
	my ($self, $lang) = @_;

	if( $lang eq 'CPP' ) {
		my $params;
		my %pkg_config = ExtUtils::PkgConfig->find(PKG_CONFIG);

		$params->{CCFLAGSEX} = join " ", (
			'-std=c++11',
			$pkg_config{cflags},
		);
		$params->{LIBS} = $pkg_config{libs};
		$params->{AUTO_INCLUDE} = q|#include <tesseract/baseapi.h>|;

		return $params;
	}
}

1;
