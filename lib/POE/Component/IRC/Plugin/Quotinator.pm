use strictures 1;

package POE::Component::IRC::Plugin::Quotinator;

# VERSION

use Getopt::Long qw(GetOptionsFromString :config pass_through);
use POE::Component::IRC::Plugin qw(:ALL);
use IRC::Utils qw(:ALL);
use Data::Dump qw[pp];

sub new {
    my ($package) = shift;
    my %args = @_;
    return bless \%args, $package;
}

sub PCI_register {
    my ($self, $irc) = @_;
    $irc->plugin_register($self, 'SERVER', qw(public));
    return 1;
}

sub PCI_unregister {
    my ($self, $irc) = @_;
    return 1;
}

sub S_public {
    my ($self, $irc) = splice @_, 0, 2;
    my ($nick, $user, $host) = parse_user(${$_[0]});
    my $channel = ${$_[1]}->[0];
    pp($channel);
    my $msg     = ${$_[2]};

    my ($cmd_args) = $msg =~ m/^!quote\s(.*)$/i;
    my ($help, $add, $del, $search, $get);
    GetOptionsFromString(
        $cmd_args,
        'help|usage|?' => \$help,
        'add=s'        => \$add,
        'del=s'        => \$del,
        'search=s'     => \$search,
        'get=s'        => \$get,
        '<>'           => sub {
            $irc->yield(
                privmsg => $channel,
                "$nick: unknown generator option, use -h for more info."
            );
        },
    );

    if ($help) {
        $irc->yield(
            privmsg => $channel,
            sprintf("%s: Usage [add|del|search|get] (id|nick) ", $nick)
        );
        return PCI_EAT_PLUGIN;
    }

    if ($add) {
        pp($add);
        $irc->yield(
            privmsg => $channel,
            sprintf("%s: Usage [add|del|search|get] (id|nick) ", $nick)
        );
        return PCI_EAT_PLUGIN;
    }

    return PCI_EAT_NONE;
}

1;

__END__

=head1 NAME

POE::Component::IRC::Plugin::Quotinator - IRC Plugin for Storing and Retreving 
quotes

=head1 SETUP

A mongo database collection must be available and passed into the argument list.

=head1 OPTIONS

=head2 B<collection>

MongoDB collection for storing/accessing the quotes.

=head1 LICENSE

This software is copyright (c) 2013 by Adam Stokes.<adamjs@cpan.org>

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
