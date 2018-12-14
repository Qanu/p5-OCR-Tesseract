use Modern::Perl;
package Renard::API::Tesseract::Inline;
# ABSTRACT: Provide Inline configuration for Tesseract

use PkgConfig;

use constant PKG_CONFIG => 'tesseract';

sub Inline {
	my ($self, $lang) = @_;

	if( $lang eq 'CPP' ) {
		my $params;
		my $pkg_config = PkgConfig->find(PKG_CONFIG);
		if( $pkg_config->errmsg ) {
			die $pkg_config->errmsg;
		}

		$params->{CCFLAGSEX} = $pkg_config->get_cflags;
		$params->{LIBS} = $pkg_config->get_ldflags;
		$params->{AUTO_INCLUDE} = q|#include <tesseract/baseapi.h>|;

		return $params;
	}
}

1;
