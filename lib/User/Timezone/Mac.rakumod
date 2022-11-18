use v6.d;

unit module Mac;

use NativeCall;
sub mac_native
    returns Str is encoded('utf8')
    is native(%?RESOURCES<macos/usertimezone.dylib>) {*}

#| Obtains the default language(s) assuming a Mac system.
sub mac is export {
    CATCH { return mac_non-native }
    return mac_native || mac_non-native;
}

sub mac_non-native {

    # Timezone, like in many *nix systems, can be determined by
    # the symbolic link at /etc/localtime.
    # NYI: also, the TZ environmental variable can be set, which
    #      should override the below.  Problem is it can be a TZ
    #      formula string too, which is more complicated to detect.
    constant localtime-path = '/etc/localtime';

    my $timezone = (run 'readlink', localtime-path, :out).out.slurp.chomp;
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