unit module Intl::UserTimezone;

#| Gets the user's timezone.  Defaults to 'Etc/GMT' (even though that's probably not a good idea).
sub user-timezone is export {
    state $ = do given $*DISTRO  {
        when .is-win   {  windows    }
        when /macosx/  {    mac      }
        when /linux/   {    nix      } # probably is the same as Mac?
        CATCH          {  default {} } # By doing nothing, we fall through to…
    } //                 'Etc/GMT'
}


# Conforming implementations for different systems should return
# simply the Olson ID.

sub mac {
    # Timezone, like in many *nix systems, can be determined by
    # the symbolic link at /etc/localtime.
    # NYI: also, the TZ environmental variable can be set, which
    #      should override the below

    localtime-alias '/etc/localtime'
}

sub nix {
    # Timezone, like in many *nix systems, can be determined by
    # the symbolic link at /etc/localtime.
    # NYI: also, the TZ environmental variable can be set, which
    #      should override the below

    localtime-alias '/etc/localtime'
}

#| Calculate timezone based on alias localtime file.
sub localtime-alias($path) {
    my $timezone = (run 'readlink', $path, :out).out.slurp;
    # Sample output:
    #   …timezone/zoneinfo/America/New_York

    # The directory structure should be stable since it comes from IANA
    # but we'll parse assuming 'zoneinfo' is stable.  Effectively, the
    # regex / 'timezone/' <( .* )> /, but this is faster:

    $timezone.substr:
            $timezone.index( 'zoneinfo' )
            + 9
}

sub windows {
    # Windows works a bit differently than the *nix variants.
    # The timezones are stored in a full descriptive name, but
    # one that is generalized across territories and doesn't
    # map nicely to the Olson/tz/IANA identifiers.

    # First, we grab the Windows timezone identifier
    my $timezone = (run 'tzutil', '/g', :out).out.slurp;
        # Sample output:
        #   "Central Standard Time"

    $timezone = "Central Standard Time";

    # Next, we get the region (CST above could be US or Canada, for instance)
    my $region = (run 'Powershell', '-command', '"Get-WinHomeLocation"', :out).out.slurp;

    $region = 244; # united states

    # Finally, we map it by first grabbing the timezone equivalency data
    state %eqv;
    once for %?RESOURCES<windows-zones.data>.IO.slurp.split(',').rotor(3)
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