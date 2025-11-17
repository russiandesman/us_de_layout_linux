Name:           us-de-layout
Version:        %{version}
Release:        %{release}%{?dist}
Summary:        German umlauts addon for US keyboard layout on Linux

License:        MIT
URL:            https://github.com/russiandesman/us_de_layout_linux
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch
Requires:       perl
Requires:       libxkbfile

%description
This package adds a custom XKB layout "en(US+DE) RAlt for l3" to the US keyboard,
allowing typing of German characters (ä, ö, ü, ß) using Right Alt + a/o/u/s combinations.
Select the layout in your desktop environment's keyboard settings after installation.

%prep
%setup -q

%build
# No build step needed (config files only)

%install
# Install symbols file
install -d -m 755 %{buildroot}/usr/share/X11/xkb/symbols
install -m 644 us-de %{buildroot}/usr/share/X11/xkb/symbols/us-de
# Create directory for backup
install -d -m 755 %{buildroot}/usr/share/%{name}

%post
layouts_file="/usr/share/X11/xkb/rules/evdev.xml"

export insert_before_string="</layoutList>"
export layout_description="
    <layout>
      <configItem>
        <name>us-de</name>
        <shortDescription>en(US+DE)</shortDescription>
        <description>en(US+DE) RAlt for l3</description>
        <languageList>
          <iso639Id>eng</iso639Id>
          <iso639Id>deu</iso639Id>
        </languageList>
      </configItem>
      <variantList/>
    </layout>
"
layout_id_string="<name>us-de</name>"

# Backup evdev.xml before modification
if [ -f /usr/share/X11/xkb/rules/evdev.xml ]; then
	cp -p /usr/share/X11/xkb/rules/evdev.xml /usr/share/%{name}/evdev.xml.backup
fi

# if not already inserted
if ! grep -q "${layout_id_string}" ${layouts_file}; then
	perl -i.backup -pe 'print "$ENV{layout_description}\n" if m|$ENV{insert_before_string}|' ${layouts_file}
fi

%postun
# Restore evdev.xml on uninstall (if $1 == 0)
if [ $1 -eq 0 ]; then
	if [ -f /usr/share/%{name}/evdev.xml.backup ]; then
		mv /usr/share/%{name}/evdev.xml.backup /usr/share/X11/xkb/rules/evdev.xml
	fi
fi

%files
%license LICENSE
/usr/share/X11/xkb/symbols/us-de
%ghost /usr/share/%{name}/evdev.xml.backup

%changelog
* Fri Nov 14 2025 Denis Maryin <des.maryin@googlemail.com> - 0.0-1
- Initial release: add US-DE layout for German umlauts on US keyboards.

