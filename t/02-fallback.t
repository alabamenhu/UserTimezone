use Test;

use Intl::UserTimezone 'This is not a real timezone';

# Once again, a test that's not really possible to test in the traditional sense.
# Before distributing a new version, insert a quick 'die' in the sub for your
# system.  This should trigger the fallback and make the commented out test
# below successfully pass.

# is user-timezone, 'This is not a real timezone';

done-testing;
