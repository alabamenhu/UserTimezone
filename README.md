# User::Timezone
**Important notice:** This module was previously known as  `Intl::UserTimezone`.  Its name was changed to align with similar modules.  It will still be usable as `Intl::UserTimezone` until the end of 2024 to give ample time for the change to happen.

A simple Raku module for determining the user's timezone as an Olson (IANA or tz) identifier, particularly useful when formatting dates.

To use:

```raku
use User::Timezone;

say user-timezone;  # 'America/New_York'
                    # 'Africa/Malabo'
                    # 'Asia/Tokyo'
                    # 'Etc/GMT'
```

The returned string does *not* apply a metazone.
If you wish to show a user-facing string like, e.g., "Central European Time", you should use the appropriate functions from `Intl::DateTime` (NYI, might go into `DateTime::*`, haven't decided yet ^_^).

## Options

The default fallback (in case detection fails) is **Etc/GMT**. 
If for some reason you wish to use a different one, pass it as a positional argument in the use statement.
Note that this has *global* effects:

    use User::Timezone 'Asia/Qyzylorda'
    
Similarly, you can *force* a certain timezone which is useful when testing out aspects of your program that may be sensitive to timezones.
To do that, include the override option.

    use User::Timezone :override;
    
This will import two additional subroutines into your scope:

    override-user-timezone(Str $olson-id)
    clear-user-timezone-override
    
These do exactly what their names imply.
Again, be aware that their effects are global.

## Compatibility / Implementation Notes

For Mac OS and most *nix systems, the region is accurately grabbed from `/etc/localtime` if it exists. 
Currently timezones indicated by the `$TZ` environmental variable are ignored, but will eventually be supported.
 
For Windows, the ID should be acceptable and better than a GMT offset, but may occasionally be suboptimal.
This is because Windows uses its own custom timezone identifiers that do not have a one-to-one relationship with Olsen IDs.
The Windows timezone ID is combined with the Windows GeoID to provide a best-guess that should generally be accurate.
For example, if your Windows timezone is "Central Standard Time", and your GeoID is 244 (United States), then it will be reported as **America/Chicago** (others are possible, but there is not enough information to differentiate with **America/Indiana/Knox**, so the broadest is used).
But if your GeoID is 39 (Canada), then it will be reported as **America/Winnipeg**.

## What if it doesn't work

If there is a problem determining the timezone, the default will be `Etc/GMT`, being the most generic, although that's not really an acceptable alternative.
If it's clear that `User::Timezone` cannot determine things for your operating system, or is in some other way not returning the correct results, please file an issue on Github and let's figure out how to make it work on your system.

# Version history

  * **v0.3.1**
    * Updated Windows zones data files
  * **v0.3.0**
      * Changed name to `User::Timezone` and added a fallback message for older uses
      * Adjusted Mac OS detection for improved accuracy
  * **v0.2**
      * Added option for a custom fallback (in case detection fails)
    * Added ability for overriding the timezone (mainly for testing purposes)
  * **v0.1.1**
    * Removed test code that prevented correct Windows detection.
    * Chomped output to facilitate use in other modules.
  * **v0.1**
    * Initial release with support for macOS, most *nix machines and beta support Windows


# License

Except as indicated, this module and all its files is provided under the Artistic License 2.0.

## Except as indicated

The file `windowsZones.xml` is Copyright 2020 The Unicode Consortium, and distributed without modification in accordance with its [license/terms of use](https://www.unicode.org/copyright.html).