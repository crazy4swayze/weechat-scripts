#!/usr/bin/perl

use strict;
use warnings;

my $bot  = ':CashBot!Bot@host-208-72-122-13.dyn.295.ca';
my $ok   = weechat::WEECHAT_RC_OK;
my $nick = 'go|dfish';

sub notice {
    my ($data, $signal, $signal_data) = @_;
    my ($sender, $msg);

# FIXME: Has to be a better way to do this
    if ($signal_data =~ /^(:\S+) NOTICE (?:\S+) (:.*)/) {
        ($sender, $msg) = ($1, $2)
    }

    return $ok unless $sender eq $bot;
    return $ok if $msg =~ /^:You have purchased/;

    my ($mins, $secs) = (0, 0);
# FIXME: might contain mins or secs or both, is there better
#    way to check?
    if ($msg =~ /(\d+)mins (\d+)secs/) {
        ($mins, $secs) = ($1, $2)
    }
    elsif ($msg =~ /(\d+)secs/) {
        $secs = $1
    }
    elsif ($msg =~ /(\d+)mins/) {
        $mins = $1;
    }
    my $duration = $mins * 60 + $secs + int rand 60;
    weechat::hook_timer($duration * 1000, 0, 1, "cash", "");
    return $ok
}

sub privmsg {
    my ($data, $signal, $signal_data) = @_;
    my ($sender, $channel, $msg);

# FIXME: Has to be a better way to do this
    if ($signal_data =~ /^(:\S+) PRIVMSG (\S+) (:.*)/) {
        ($sender, $channel, $msg) = ($1, $2, $3)
    }

    return $ok unless $channel eq '#gunbuy';
    return $ok unless $sender eq $bot;
    return $ok unless $msg =~ /^:\Q$nick/;

    if ($msg =~ /\Q$nick\E now has (\S+) dollars/) {
        my $dollars = $1;
        $dollars =~ y/,//d;
        buy($dollars)
    }
    return $ok
}

sub buy {
    my ($dollars) = @_;
    my $amount = int($dollars / 5000);
    if ($amount > 0) {
#FIXME: better way to find the channel?
        my $buffer = weechat::info_get("irc_buffer", "he,#gunbuy");
        weechat::command($buffer, "!buy gun $amount");
    }
    weechat::hook_timer(int((20 + rand 60) * 1000), 0, 1, "cash", "");
    return $ok
}

sub cash {
#FIXME: better way to find the channel?
    my $buffer = weechat::info_get("irc_buffer", "he,#gunbuy");
    weechat::command($buffer, "\@cash");
    return $ok
}

weechat::register("cashbot", "goldfish\@redbrick.dcu.ie", "0.1", "GPL3", "play cashbot", "", "");
weechat::hook_signal("*,irc_in2_notice", "notice", "");
weechat::hook_signal("*,irc_in2_privmsg", "privmsg", "");
