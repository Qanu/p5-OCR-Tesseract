use Modern::Perl;
package Renard::API::Tesseract::Inline;
# ABSTRACT: Provide Inline configuration for Tesseract

use ExtUtils::PkgConfig;
use File::Basename;
use File::Spec;

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
		$params->{LIBS} = join " ", qw(:nosearch), $pkg_config{libs}, qw(:search);
		$params->{AUTO_INCLUDE} = q|#include <tesseract/baseapi.h>|;

		my $dir = File::Spec->rel2abs( dirname(__FILE__) );
		$params->{TYPEMAPS} = File::Spec->catfile( $dir, 'typemap' );

		return $params;
	}
}

1;
