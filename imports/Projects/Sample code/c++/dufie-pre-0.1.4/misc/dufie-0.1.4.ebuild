# Copyright 2005 Daga <http://daga.dyndns.org>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"
DESCRIPTION="Dufie, the 'DU' Front [i] End"
SRC_URI="http://daga.dyndns.org/projects/dufie/${P}.tar.gz"
HOMEPAGE="http://daga.dyndns.org/projects/dufie/"
IUSE=""
DEPEND=">=x11-libs/gtk+-2.1.2
	sys-devel/gettext
	sys-apps/coreutils"

DOCS="AUTHORS ChangeLog README TODO"

src_compile() {
	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "install failed"
	dodoc "${DOCS}"

	insinto /usr/share/applications
	doins "${S}/dufie.desktop"
}

