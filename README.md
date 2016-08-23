# NAME

Net::Statsite::Client - Object-Oriented Client for [statsite](http://armon.github.io/statsite) server

# SYNOPSIS

    use Net::Statsite::Client;
    my $statsite = Net::Statsite::Client->new(
        host   => 'localhost',
        prefix => 'test',
    );

    $statsite->increment('item'); #increment key test.item

# DESCRIPTION

Net::Statsite::Client is based on [Etsy::StatsD](https://metacpan.org/pod/Etsy::StatsD) but with new - `new` interface and `unique` method.

# METHODS

## new (host => $host, port => $port, sample\_rate => $sample\_rate, prefix => $prefix)

Create a new instance.

_host_ - hostname of statsite server (default: localhost)

_port_ - port of statsite server (port: 8125)

_sample\_rate_ - rate of sends metrics (default: 1)

_prefix_ - prefix metric name (default: '')

## timing(STAT, TIME, SAMPLE\_RATE)

Log timing information (should be in miliseconds)

## increment(STATS, SAMPLE\_RATE)

Increment one of more stats counters.

## decrement(STATS, SAMPLE\_RATE)

Decrement one of more stats counters.

## update(STATS, DELTA, SAMPLE\_RATE)

Update one of more stats counters by arbitrary amounts.

## unique(STATS, ITEM, SAMPLE\_RATE)

Unique Set

For example if you need count of unique ip adresses (per flush interval)
    $stats->unique('ip.unique', $ip);

## gauge(STATS, VALUE, SAMPLE\_RATE)

Gauge Set (Gauge, similar to  kv  but only the last value per key is retained)

## send(DATA, SAMPLE\_RATE)

Sending logging data; implicitly called by most of the other methods.

# LICENSE

Copyright (C) Avast Software.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Jan Seidl <seidl@avast.com>
