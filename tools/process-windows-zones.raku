#!/usr/bin/env perl6

# The file 'windowsZones.xml' must be present in this file
# It can obtained from cldr/common/supplemental/windowsZones.xml
# and should be updated about every six months in accordance with
# the CLDR timeline.

use XML;
my $tz-output-file = $*PROGRAM.parent.parent.add('resources/windows-zones.data').resolve.IO;

my @win-zones = from-xml-file($*PROGRAM.sibling('windowsZones.xml').Str).elements(:TAG<mapZone> :RECURSE);

my @items;
for @win-zones {
    @items.append:
        .<other>,           # Windows TZ id
        .<type>             # Olson TZ id
            .split(/\h+/)   #   (some correspond to more than one, but there will be no way
            .head,          #    to determine with more precision.  First is most general.)
        .<territory>        # CLDR region id
}
@items.append( .<other    type    territory> ) for @win-zones;
             #   win-id  cldr-id   region

$tz-output-file.spurt: @items.join("\n");

