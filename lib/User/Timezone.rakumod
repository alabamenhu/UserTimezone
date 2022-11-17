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

    use User::Timezone::Windows:auth<zef:guifa>;
    use User::Timezone::Mac:auth<zef:guifa>;
    use User::Timezone::Linux:auth<zef:guifa>;

    #| Obtains the user's timezone as an Olson ID
    sub user-timezone (--> Str) {
        .return with $UserTimezone::timezone;
        $UserTimezone::timezone = do given $*DISTRO  {
            when .is-win  {  windows    }
            when /macos/  {    mac      }
            when /linux/  {   linux     } # probably is the same as Mac?
            CATCH         {  default {} } # By doing nothing, we fall through to…
        } // #`[error] $UserTimezone::fallback
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