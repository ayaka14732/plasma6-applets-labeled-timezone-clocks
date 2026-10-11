# Maintainer: Labeled Time Zone Clocks Contributors

pkgname=plasma6-applets-labeled-timezone-clocks
pkgver=1.1.2
pkgrel=1
pkgdesc='Compact, configurable Plasma 6 panel clocks for multiple time zones'
arch=('any')
url='https://github.com/ayaka14732/plasma6-applets-labeled-timezone-clocks'
license=('GPL-2.0-or-later')
depends=('plasma-workspace>=6.7')
options=('!debug')
source=(
    'metadata.json'
    'config.qml'
    'main.xml'
    'configGeneral.qml'
    'main.qml'
    'README.md'
    'LICENSE'
)
sha256sums=(
    '8372a3aade7e8c98bb03861f5fef40bc705da76a1f070251c9f8d188bc619ba4'
    'f9d6dde90c03f77c2c406c2c12e5f9e14a777df556b0574878fcaac84c1e9a3a'
    '2eaff509e21080386e77d1b7667466f34789dd604c5ef3d47ab45ebf81a65694'
    '568b5c852d1d2cd1d447a24b14adfa9c785d9827e7761645824ac6661ad4afe1'
    '8a6f47bacd89687d1cb34f3c73e0b535e9d11d1d94a3c37ee0d683f1998fafeb'
    '3fbe63c29e3dfe1138d8e5edecaed73aa3a73d467b1010c9b5d8fcf0e5e1ac05'
    'aaf135472f81c5b4a0dca9367e5bb5e9750032b5bebe5442b36e4c0a47430df3'
)

package() {
    local applet_dir="$pkgdir/usr/share/plasma/plasmoids/local.labeledtimezoneclock"

    install -Dm644 "$srcdir/metadata.json" "$applet_dir/metadata.json"
    install -Dm644 "$srcdir/config.qml" "$applet_dir/contents/config/config.qml"
    install -Dm644 "$srcdir/main.xml" "$applet_dir/contents/config/main.xml"
    install -Dm644 "$srcdir/configGeneral.qml" "$applet_dir/contents/ui/configGeneral.qml"
    install -Dm644 "$srcdir/main.qml" "$applet_dir/contents/ui/main.qml"
    install -Dm644 "$srcdir/README.md" "$pkgdir/usr/share/doc/$pkgname/README.md"
    install -Dm644 "$srcdir/LICENSE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
