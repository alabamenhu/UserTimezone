use Test;

use Intl::UserTimezone :override;

# Test the override by putting in a fake timezone
# since UserTimezone does not check for validity since
# the database isn't guaranteed stable.
my $original-tz = user-timezone;

override-user-timezone("This is not a real timezone");

is user-timezone(), "This is not a real timezone";
clear-user-timezone-override;
is user-timezone(), $original-tz;

done-testing;