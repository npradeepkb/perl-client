#! /usr/bin/perl

use strict;
use warnings;
use JSON;
use Test::More;
use Appium::Element;
use Cwd qw/abs_path/;

BEGIN: {
    my $test_lib = abs_path(__FILE__);
    $test_lib =~ s/(.*)\/.*\.t$/$1\/lib/;
    push @INC, $test_lib;
    require MockAppium;

    unless (use_ok('Appium::Commands')) {
        BAIL_OUT("Couldn't load Appium::Commands");
        exit;
    }
}


my $mock_appium = MockAppium->new;

my @implemented = qw/
                        contexts
                        current_context
                        hide_keyboard
                    /;

my $cmds = Appium::Commands->new->get_cmds;

DRIVER_COMMANDS: {
    foreach my $command (@implemented) {
        my ($res, undef) = $mock_appium->$command;
        ok(delete $cmds->{ $res->{command} }, $command . ' is in found in the Commands hash');
    }
}

SWITCH_TO_COMMANDS: {
    my @switch_to_implemented = qw/ context /;

    foreach my $command (@switch_to_implemented) {
        my ($res, undef) = $mock_appium->switch_to->$command;
        ok(delete $cmds->{ $res->{command} }, 'switch: ' . $command . ' is in found in the Commands hash');
    }
}

ELEMENT_COMMANDS: {
    my @element_implemented = qw/ set_text /;
    my $elem = Appium::Element->new(
        id => 0,
        driver => $mock_appium
    );

    foreach my $command (@element_implemented) {
        my ($res, undef) = $elem->$command( '' );
        ok(delete $cmds->{ $res->{command} }, 'elem: ' . $command . ' is in found in the Commands hash');
    }

}

# There are 68 commands that we inherit from S::R::Commands. We add
# our own, and then delete them one by one in each foreach loop
# above. By the time we get here, there should only be the original 68
# left.
ok( scalar keys %{ $cmds } == 68, 'All Appium Commands are implemented!');

done_testing;