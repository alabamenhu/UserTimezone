use v6.d;

unit module Windows;

sub windows is export {
    # Windows works a bit differently than the *nix variants.
    # The timezones are stored in a full descriptive name, but
    # one that is generalized across territories and doesn't
    # map nicely to the Olson/tz/IANA identifiers.

    # First, we grab the Windows timezone identifier
    my $timezone = (run 'tzutil', '/g', :out).out.slurp.chomp;
    # Sample output:
    #   "Central Standard Time"

    # Next, we get the region (CST above could be US or Canada, for instance)
    my $region = (run 'Powershell', '-command', '"Get-WinHomeLocation"', :out).out.slurp.chomp;

    # Finally, we map it by first grabbing the timezone equivalency data
    state %eqv;
    once for %?RESOURCES<windows-zones.data>.IO.slurp.split("\n").rotor(3)
    -> ($win, $cldr, $region) {
        %eqv{$win}{$region} = $cldr;
    }

    state %eqv-region;
    once for %?RESOURCES<windows-regions.data>.IO.slurp.lines {
        next unless $_ ~~ / $<win>=[<[0..9]>+]       # windows code (always numeric)
        <ws>
        $<cldr>=[<[0..9A..Z]>+]  # CLDR code (alpha or numeric)
        <ws>
        [ '#' .* ]?              # comment
        /;
        %eqv-region{ ~$<win> } = ~$<cldr>;
    }

    my $cldr-region = %eqv-region{$region};
    my $olson  = %eqv{$timezone}{$cldr-region}
        // %eqv{$timezone}<001>
        // 'Etc/GMT';

    $olson
}


