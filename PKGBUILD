# Maintainer: Labeled Time Zone Clocks Contributors

pkgname=plasma6-applets-labeled-timezone-clocks
pkgver=1.1.1
pkgrel=1
pkgdesc='Compact, configurable Plasma 6 panel clocks for multiple time zones'
arch=('any')
license=('GPL-2.0-or-later')
depends=('plasma-workspace>=6.0')
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
    '32aefe92eef556484d29042f486e2edf9ae9661053e3d720568920100dfe6fca'
    'f9d6dde90c03f77c2c406c2c12e5f9e14a777df556b0574878fcaac84c1e9a3a'
    '2eaff509e21080386e77d1b7667466f34789dd604c5ef3d47ab45ebf81a65694'
    '8f1d09ac23c4ca7dec16fb0c11a695fc78ef346a3e886728c8ef1be6f1c6f6a4'
    '43594c5732aa31cc21687b68605d4785a8f873a8615e781d62cb10d4954ba08b'
    'c951481c168e370441efcf9ddb12e24f803a9cfc10b3e6f33338af5b65f3e3b6'
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
