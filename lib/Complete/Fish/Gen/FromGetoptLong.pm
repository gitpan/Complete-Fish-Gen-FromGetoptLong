package Complete::Fish::Gen::FromGetoptLong;

our $DATE = '2014-11-29'; # DATE
our $VERSION = '0.01'; # VERSION

use 5.010001;
use strict;
use warnings;

use Getopt::Long::Util qw(parse_getopt_long_opt_spec);
use String::ShellQuote;

our %SPEC;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(gen_fish_complete_from_getopt_long_spec);

$SPEC{gen_fish_complete_from_getopt_long_spec} = {
    v => 1.1,
    summary => 'From Getopt::Long spec, generate tab completion '.
        'commands for the fish shell',
    description => <<'_',


_
    args => {
        spec => {
            summary => 'Getopt::Long options specification',
            schema => 'hash*',
            req => 1,
            pos => 0,
        },
        cmdname => {
            summary => 'Command name',
            schema => 'str*',
        },
    },
    result => {
        schema => 'str*',
        summary => 'A script that can be fed to the fish shell',
    },
};
sub gen_fish_complete_from_getopt_long_spec {
    my %args = @_;

    my $gospec = $args{spec} or return [400, "Please specify 'spec'"];

    my $cmdname = $args{cmdname};
    if (!$cmdname) {
        ($cmdname = $0) =~ s!.+/!!;
    }

    my @cmds;
    my $prefix = "complete -c ".shell_quote($cmdname);
    push @cmds, "$prefix -e"; # currently does not work (fish bug)
    for my $ospec (sort keys %$gospec) {
        my $res = parse_getopt_long_opt_spec($ospec)
            or die "Can't parse option spec '$ospec'";
        $res->{min_vals} //= $res->{type} ? 1 : 0;
        $res->{max_vals} //= $res->{type} || $res->{opttype} ? 1:0;
        for my $o0 (@{ $res->{opts} }) {
            my @o = $res->{is_neg} && length($o0) > 1 ?
                ($o0, "no$o0", "no-$o0") : ($o0);
            for my $o (@o) {
                my $cmd = $prefix;
                $cmd .= length($o) > 1 ? " -l '$o'" : " -s '$o'";
                # XXX where to get summary from?
                if ($res->{min_vals} > 0) {
                    $cmd .= " -r -f -a ".shell_quote("(begin; set -lx COMP_SHELL fish; set -lx COMP_LINE (commandline); set -lx COMP_POINT (commandline -C); ".shell_quote($cmdname)."; end)");
                }
                push @cmds, $cmd;
            }
        }
    }
    [200, "OK", join("", map {"$_\n"} @cmds)];
}

1;
# ABSTRACT: Generate tab completion commands for the fish shell

__END__

=pod

=encoding UTF-8

=head1 NAME

Complete::Fish::Gen::FromGetoptLong - Generate tab completion commands for the fish shell

=head1 VERSION

This document describes version 0.01 of Complete::Fish::Gen::FromGetoptLong (from Perl distribution Complete-Fish-Gen-FromGetoptLong), released on 2014-11-29.

=head1 SYNOPSIS

=head1 FUNCTIONS


=head2 gen_fish_complete_from_getopt_long_spec(%args) -> [status, msg, result, meta]

From Getopt::Long spec, generate tab completion commands for the fish shell.

Arguments ('*' denotes required arguments):

=over 4

=item * B<cmdname> => I<str>

Command name.

=item * B<spec>* => I<hash>

Getopt::Long options specification.

=back

Return value:

Returns an enveloped result (an array).

First element (status) is an integer containing HTTP status code
(200 means OK, 4xx caller error, 5xx function error). Second element
(msg) is a string containing error message, or 'OK' if status is
200. Third element (result) is optional, the actual result. Fourth
element (meta) is called result metadata and is optional, a hash
that contains extra information.

A script that can be fed to the fish shell (str)

=head1 SEE ALSO

This module is used by L<Getopt::Long::Complete>.

L<Perinci::Sub::To::FishComplete>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Complete-Fish-Gen-FromGetoptLong>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-Complete-Fish-Gen-FromGetoptLong>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Complete-Fish-Gen-FromGetoptLong>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
