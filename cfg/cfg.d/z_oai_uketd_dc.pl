# Config file (editable by EPMC screen)


# Map this plugin over the one supplied with EPrints
$c->{plugin_alias_map}->{"Export::OAI_UKETD_DC"} = "Export::OAI_UKETD_DC_2017";
$c->{plugin_alias_map}->{"Export::OAI_UKETD_DC_2017"} = undef;

$c->{plugins}->{"OAI_UKETD_DC"}->{params}->{creator_and_orcid} = sub {
        my( $plugin, $eprint ) = @_;

        my @dc_creators = ();
        my @orcids = ();

        my $creators = $eprint->get_value( "creators" );
        if( defined $creators )
        {
                foreach my $creator ( @{$creators} )
                {
                        push @dc_creators, [ "creator", EPrints::Utils::make_name_string( $creator->{name} ), "dc" ];
                        if( defined $creator->{id} && $creator->{id} =~ m/0{4}/ ){
                                push @orcids, [ "authoridentifier", $plugin->format_orcid( $creator->{orcid} ), "uketdterms", { "xsi:type" => "uketdterms:ORCID", "rel" => "author" }  ];
                        }
                }
        }

        return @dc_creators, @orcids;

};
