#! /bin/bash

cp us-de /usr/share/X11/xkb/symbols

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

# if not already inserted
if ! grep -q "${layout_id_string}" ${layouts_file}; then
	perl -i.backup -pe 'print "$ENV{layout_description}\n" if m|$ENV{insert_before_string}|' ${layouts_file}
fi

