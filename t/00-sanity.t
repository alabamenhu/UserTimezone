=begin pod
=head1 Sanity Test

There really isn't much more that we can do here.
Each system will need to be manually tested and they cannot be simulated.

This module has currently been actually tested on the following systems
and confirmed to display correct Olson IDs.

=table
    System   |  Version  | Tested by
    =========|===========|==========
    Mac      |  10.15    | Matéu
    Mac      |  12.6     | Matéu
=end pod

use Test;
use User::Timezone;

isnt user-timezone, Nil;

done-testing;
