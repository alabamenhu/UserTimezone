#unit module Intl::UserTimezone;

my package UserTimezone {
    my Str $timezone;        #= The user's timezone
    my Str $timezone-backup; #= The user's timezone (when being overridden)
    my Str $fallback;        #= The fallback timezone
}



sub EXPORT (
    Str $fallback-timezone? #= The timezone to use as the zone if detection fails
) {
    # The default fallback is just plain old GMT.
    $UserTimezone::fallback = $fallback-timezone // 'Etc/GMT';

    #| Obtains the user's timezone as an Olson ID
    sub user-timezone (--> Str) {
        .return with $UserTimezone::timezone;
        $UserTimezone::timezone = do given $*DISTRO  {
            when .is-win   {  windows    }
            when /macosx/  {    mac      }
            when /linux/   {    nix      } # probably is the same as Mac?
            CATCH          {  default {} } # By doing nothing, we fall through to…
        } // #`[error] $UserTimezone::fallback
    }

    sub mac {
        # Like in many *nix systems, the tz can be determined by the
        # symbolic link at /etc/localtime.
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

    #| Calculate timezone based on alias localtime file
    #| (common for Mac/*Nix machines).
    sub localtime-alias(
            $path #= The path to the localtime file
    ) {
        my $timezone = (run 'readlink', $path, :out).out.slurp.chomp;
        # Sample output:
        #   …timezone/zoneinfo/America/New_York
        # Note that readlink is not POSIX, but does appear to be available on
        # many systems.  It may be that .resolve can get us the same location
        # natively (to be tested later).

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
        my $timezone = (run 'tzutil', '/g', :out).out.slurp.chomp;
            # Sample output:
            #   "Central Standard Time"

        # Next, we get the region (CST above could be US or Canada, for instance)
        my $region = (run 'Powershell', '-command', '"Get-WinHomeLocation"', :out).out.slurp.chomp;

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

    Map.new:
        '&user-timezone' => &user-timezone;

}

# Simple addition of two subs to enable the override, which just
# temporarily swap out whatever we would have returned before.
my package EXPORT::override {
    &OUR::override-user-timezone := sub override-user-timezone(Str $timezone) {
        $UserTimezone::timezone-backup = $UserTimezone::timezone;
        $UserTimezone::timezone        =               $timezone;
    }
    &OUR::clear-user-timezone-override := sub clear-user-timezone-override {
        $UserTimezone::timezone = $UserTimezone::timezone-backup;
    }
}