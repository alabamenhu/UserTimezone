#import <Foundation/Foundation.h>
// Compiling from the command line:
//     gcc -framework Foundation -x objective-c -o macos.o macos.m // this does a Linux-style library
//     clang -undefined dynamic_lookup -framework Foundation -dynamiclib -o macos.dylib macos.m // this does a Mac-style dylib
// This should be handled automatically by the build-native.raku script

const char* mac_native() {

    // Pool needed for garbage collection
    id pool=[NSAutoreleasePool new];

    // Obtain the user's current locale
    NSTimeZone *timezone    = [NSTimeZone systemTimeZone];
    NSString   *timezoneID  = [timezone name];

    // Returning the result of [timezoneID UTF8String] can't be done because,
    // per NSString documentation, it's an internal pointer. By making
    // a copy, we guarantee that NativeCall won't end up with deallocated
    // stuff (results in a segmentation fault!)
    const char* final = [[NSString stringWithString: timezoneID] UTF8String];

    // End using the pool
    [pool drain];

    return final;
}

/** MAIN
 * Exists only in case we need to test our code and don't want to have
 * to call it from NativeCall.  It won't ever be called by Raku code.
 * The simplest way to compile this one to test would be
 *    clang -framework Foundation macos.m -o macos_test; ./macos_test
 */
int main() {
    fprintf(
        stdout,
        "Per macOS, the current Olson ID is '%s'.\n",
        mac_native()
    );
    return 0;
}