![Intl::UserTimezone for Raku](docs/logo.png)

**Important notice:** This module *may* eventually be renamed to `DateTime::UserTimezone` prior to its 1.0 release; if that occurs, it will continue to *provide* under the current name for at least one year.  

A simple Raku module for determining the user's timezone as an Olson (IANA or tz) identifier, particularly useful when formatting dates.

To use:

```raku
use Intl::UserTimezone

say user-timezone;  # 'America/New_York'
                    # 'Africa/Malabo'
                    # 'Asia/Tokyo'
                    # 'Etc/GMT'
```

The returned string does *not* apply a metazone.
If you wish to show a user-facing string like, e.g., "Central Europe Time", you should use the appropriate functions from `Intl::DateTime` (NYI, might go into `DateTime::*`, haven't decided yet ^_^).

For Mac OS and most *nix systems, the region is accurately grabbed from `/etc/localtime` if it exists. 
Currently timezones indicated by the `$TZ` environmental variable are ignored, but will eventually be supported.

For Windows, the ID should be acceptable and better than a GMT offset, but may occasionally be suboptimal.
This is because Windows uses its own custom timezone identifiers that do not have a one-to-one relationship with Olsen IDs.
The Windows timezone ID is combined with the Windows GeoID to provide a best-guess that should generally be accurate.
For example, if your Windows timezone is "Central Standard Time", and your GeoID is 244 (United States), then it will be reported as **America/Chicago** (others are possible, but there is not enough information to differentiate with **America/Indiana/Knox**, so the broadest is used).
But if your GeoID is 39 (Canada), then it will be reported as **America/Winnipeg**.

## Options

Oftentimes the user may not be aware of their Olsen ID.
You may prefer to use the aliased forms such that **America/New_York** appears as **America/Eastern**;

## What if it doesn't work

If there is a problem determining the timezone, the default will be `Etc/GMT`, being the most generic.
If it's clear that `UserTimezone` cannot determine things for your operating system, or is in some other way not returning the correct results, please file an issue on Github and let's figure out how to make it work on your system.

# Version history

- **0.1**  
Initial release with support for Mac, some *nix machines, and (hopefully) Windows

# License

Except as indicated, this module and all its files is provided under the Artistic License 2.0.

## Except as indicated

The file `windowsZones.xml` is Copyright 2020 The Unicode Consortium, and distributed without modification in accordance with its [license/terms of use](https://www.unicode.org/copyright.html).