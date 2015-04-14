package Net::Statsite::Client;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.1.0";

use IO::Socket;
use Carp;

=head1 NAME

Net::Statsite::Client - Object-Oriented Client for statsite Server

=head1 SYNOPSIS

    use Net::Statsite::Client;
    my $statsite = Net::Statsite::Client->new(
        host   => 'localhost',
        prefix => 'test',
    );

    $statsite->increment('item'); #increment key test.item

=head1 DESCRIPTION

Net::Statsite::Client is based on Etsy::StatsD

=head1 METHODS

=head2 new (HOST, PORT, SAMPLE_RATE)

Create a new instance.

=cut

sub new {
    my ($class, $host, $port, $sample_rate, $prefix) = @_;
    $host   = 'localhost' unless defined $host;
    $port   = 8125        unless defined $port;
    $prefix = ''          unless defined $prefix;

    my $sock = new IO::Socket::INET(
        PeerAddr => $host,
        PeerPort => $port,
        Proto    => 'udp',
    ) or croak "Failed to initialize socket: $!";

    bless { socket => $sock, sample_rate => $sample_rate, prefix => $prefix }, $class;
}

=head2 timing(STAT, TIME, SAMPLE_RATE)

Log timing information

=cut

sub timing {
    my ($self, $stat, $time, $sample_rate) = @_;
    $self->send({ $stat => "$time|ms" }, $sample_rate);
}

=head2 increment(STATS, SAMPLE_RATE)

Increment one of more stats counters.

=cut

sub increment {
    my ($self, $stats, $sample_rate) = @_;
    $self->update($stats, 1, $sample_rate);
}

=head2 decrement(STATS, SAMPLE_RATE)

Decrement one of more stats counters.

=cut

sub decrement {
    my ($self, $stats, $sample_rate) = @_;
    $self->update($stats, -1, $sample_rate);
}

=head2 update(STATS, DELTA, SAMPLE_RATE)

Update one of more stats counters by arbitrary amounts.

=cut

sub update {
    my ($self, $stats, $delta, $sample_rate) = @_;
    $delta = 1 unless defined $delta;
    my %data;
    if (ref($stats) eq 'ARRAY') {
        %data = map { $_ => "$delta|c" } @$stats;
    }
    else {
        %data = ($stats => "$delta|c");
    }
    $self->send(\%data, $sample_rate);
}

=head2 unique(STATS, ITEM, SAMPLE_RATE)

Unique Set

=cut

sub unique {
    my ($self, $stats, $item, $sample_rate) = @_;
    my %data = ($stats => "$item|s");
    $self->send(\%data, $sample_rate);
}

=head2 gauge(STATS, VALUE, SAMPLE_RATE)

Gauge Set (Gauge, similar to  kv  but only the last value per key is retained)

=cut

sub gauge {
    my ($self, $stats, $value, $sample_rate) = @_;
    my %data = ($stats => "$value|g");
    $self->send(\%data, $sample_rate);
}

=head2 send(DATA, SAMPLE_RATE)

Sending logging data; implicitly called by most of the other methods.

=cut

sub send {
    my ($self, $data, $sample_rate) = @_;
    $sample_rate = $self->{sample_rate} unless defined $sample_rate;

    my $sampled_data;
    if (defined($sample_rate) and $sample_rate < 1) {
        while (my ($stat, $value) = each %$data) {
            $sampled_data->{$stat} = "$value|\@$sample_rate" if rand() <= $sample_rate;
        }
    }
    else {
        $sampled_data = $data;
    }

    return '0 but true' unless keys %$sampled_data;

    #failures in any of this can be silently ignored
    my $count  = 0;
    my $socket = $self->{socket};
    while (my ($stat, $value) = each %$sampled_data) {

        my $key = $stat;
        if ($$self{prefix}) {
            $key = "$$self{ prefix }.$stat";
        }

        #sanitize key (remove statsite separators)
        #https://github.com/armon/statsite#protocol
        $key =~ s/[:|]/_/g;

        _send_to_sock($socket, "$key:$value\n");
        ++$count;
    }
    return $count;
}

sub _send_to_sock( $$ ) {
    my ($sock, $msg) = @_;
    CORE::send($sock, $msg, 0);
}

=head1 LICENSE

Copyright (C) Avast Software.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jan Seidl E<lt>seidl@avast.comE<gt>

=cut

1;
