use strict;
use warnings;

our $VERSION = '1.0.0';

use File::Spec::Functions qw(catfile);
use FindBin qw($Bin);
use Test::More tests => 19;
use Test::MockModule;

use lib catfile($Bin, '../../../lib');

use_ok('Net::Statsite::Client');

is($Net::Statsite::Client::VERSION, $VERSION, 'test-module version check');

my $module = Test::MockModule->new('Net::Statsite::Client');
my $data;

$module->mock(
	send => sub {
		$data = $_[1];
	}
);

my $bucket = 'test';
my $update = 5;
my $time = 1234;

ok (my $statsd = Net::Statsite::Client->new );
is ( $statsd->{socket}->peerport, 8125, 'used default port');

$data = {};
ok( $statsd->timing($bucket,$time) );
is ( $data->{$bucket}, "$time|ms");

$data = {};
ok( $statsd->increment($bucket) );
is( $data->{$bucket}, '1|c');

$data = {};
ok( $statsd->decrement($bucket) );
is( $data->{$bucket}, '-1|c');

$data = {};
ok( $statsd->update($bucket, $update) );
is( $data->{$bucket}, "$update|c");

$data = {};
ok( $statsd->update($bucket) );
is( $data->{$bucket}, "1|c");

$data = {};
ok( $statsd->update(['a','b']) );
is( $data->{a}, "1|c");
is( $data->{b}, "1|c");

ok ( my $remote = Net::Statsite::Client->new(port => 123));
is ( $remote->{socket}->peerport, 123, 'used specified port');
