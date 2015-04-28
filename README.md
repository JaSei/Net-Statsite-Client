# NAME

Net::Statsite::Client - Object-Oriented Client for statsite Server

# SYNOPSIS

    use Net::Statsite::Client;
    my $statsite = Net::Statsite::Client->new(
        host   => 'localhost',
        prefix => 'test',
    );

    $statsite->increment('item'); #increment key test.item

# DESCRIPTION

Net::Statsite::Client is based on Etsy::StatsD

# METHODS

## new (host => $host, port => $port, sample\_rate => $sample\_rate, prefix => $prefix)

Create a new instance.

host - hostname of statsite server (default: localhost)
port - port of statsite server (port: 8125)
sample\_rate - rate of sends metrics (default: 1)
prefix - prefix metric name (default: '')

## timing(STAT, TIME, SAMPLE\_RATE)

Log timing information

## increment(STATS, SAMPLE\_RATE)

Increment one of more stats counters.

## decrement(STATS, SAMPLE\_RATE)

Decrement one of more stats counters.

## update(STATS, DELTA, SAMPLE\_RATE)

Update one of more stats counters by arbitrary amounts.

## unique(STATS, ITEM, SAMPLE\_RATE)

Unique Set

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
