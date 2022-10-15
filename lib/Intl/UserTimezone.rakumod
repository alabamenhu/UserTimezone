sub EXPORT {
    use User::Timezone;
    note "⎡ The module Intl::UserTimezone has been renamed to User::Timezone. ⎤\n"
       ~ "⎢ Please use this name in the future. If you received this message  ⎥\n"
       ~ "⎢ without having explicitly used the module, please contact the     ⎥\n"
       ~ "⎢ author whose module called this to have them update accordingly.  ⎥\n"
       ~ "⎢                                                                   ⎥\n"
       ~ "⎢ You may dismiss this by setting the environment variable          ⎥\n"
       ~ "⎢ RAKU_USERTIMEZONE_NAMECHANGE_WARNING to OFF. Updates after 2024   ⎥\n"
       ~ "⎣ will no longer provide under the old name.                        ⎦"
    unless %*ENV<RAKU_USER_TIMEZONE_NAMECHANGE_WARNING> // '' eq 'OFF';
    Map.new: '&user-timezone' => &user-timezone;

}

my package EXPORT::override {
    use User::Timezone:auth<zef:guifa> :override;
    OUR::<&clear-user-timezone-override> = &clear-user-timezone-override;
    OUR::<&override-user-timezone>       = &override-user-timezone;
}