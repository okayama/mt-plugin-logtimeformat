package MT::Plugin::LogTimeFormat;
use strict;
use MT;
use MT::Plugin;
use base qw( MT::Plugin );
@MT::Plugin::LogTimeFormat::ISA = qw( MT::Plugin );

use MT::Util qw( epoch2ts ts2epoch offset_time format_ts );

my $PLUGIN_NAME = 'LogTimeFormat';
my $VERSION = '0.1';

my $plugin = __PACKAGE__->new( {
    id => $PLUGIN_NAME,
    key => lc $PLUGIN_NAME,
    name => $PLUGIN_NAME,
    author_name => 'okayama',
    author_link => 'http://weeeblog.net/',
    description => '<__trans phrase="Change log time fomat.">',
    version => $VERSION,
    l10n_class => 'MT::' . $PLUGIN_NAME . '::L10N',
    system_config_template => lc $PLUGIN_NAME . '_config.tmpl',
    settings => new MT::PluginSettings( [
        [ 'format', { Default => '%Y-%m-%d %H:%M:%S' } ],
    ] ),
} );
MT->add_plugin( $plugin );

sub init_registry {
    my $plugin = shift;
    $plugin->registry( {
        list_properties => {
            log => {
                created_on => {
                    html => sub {
                        my $prop = shift;
                        my ( $obj, $app, $opts ) = @_;
                        my $ts = $obj->created_on;
                        my $blog = $opts->{ blog };
                        my $epoch = ts2epoch( undef, $ts, 1 );
                        if ( ( time() - $epoch ) <= 60 ) {
                            return MT->translate( 'moments ago' );
                        }
                        $epoch = offset_time( $epoch, $blog );
                        $ts = epoch2ts( $blog, $epoch, 1 );
                        return format_ts( $plugin->get_config_value( 'format' ), $ts, undef, $app->user ? $app->user->preferred_language : undef );
                    },
                },
            },
        },
    } );
}

1;