# Config file (editable by EPMC screen)

# Firstly, enable this plugin.
$c->{plugins}->{"Export::OAI_UKETD_DC_2017"}->{params}->{disable} = 0;

# Map this plugin over the one supplied with EPrints
# Unsetting the metadataPrefix stops the default one appearing in the OAI-PMH interface
# NB if two plugins can supply the same metadataPrefix for the OAI-PMH interface, which
# one is actually used isn't defined - there is not ordering, or preference for them.
# For this reason, we have to set the default metadataPrefix to undef.
$c->{plugins}->{"Export::OAI_UKETD_DC"}->{params}->{metadataPrefix} = undef;
# and setting the new Export plugin's prefix makes it appear.
$c->{plugins}->{"Export::OAI_UKETD_DC_2017"}->{params}->{metadataPrefix} = "uketd_dc";

# An alternative way is to alias the plugin
# Leave these lines commented out unless you're sure you know what you're doing!
### $c->{plugin_alias_map}->{"Export::OAI_UKETD_DC"} = "Export::OAI_UKETD_DC_2017";
### $c->{plugin_alias_map}->{"Export::OAI_UKETD_DC_2017"} = undef;


# This new version of the UKETD_DC profile has some configuration options to make it easier for you to 
# make your data available to the EThOS service
#
# The sections below can be un-commented and altered to suit the configuration of your repository.
#

###################################################################################
#
# thesis_type_to_qualname
# Map the internal values to 'human readable' versions. These should include a 
# trailing full-stop if necessary.
# By default, 'phd' is mapped to 'Ph.D.', and 'engd' is mapped to 'Eng.D.'.
#
###################################################################################

#$c->{plugins}->{"OAI_UKETD_DC"}->{params}->{thesis_type_to_qualname} =  {
#	phd   => "Ph.D.",
#	engd  => "Eng.D.",
#	mphil => "M.Phil.",
#};

###################################################################################
# 
# thesis_type_to_quallevel
# Map the thesis types to e.g. 'Doctoral' or 'Masters'
#
###################################################################################

#$c->{plugins}->{"OAI_UKETD_DC"}->{params}->{thesis_type_to_quallevel} =  {
#	phd   => "Doctoral",
#	engd  => "Doctoral",
#	mphil => "Masters",
#};


###################################################################################
#
# lang_to_3char
# May any language values used (EPrints normally uses 2-character codes, but a 
# language field could also use values such as 'English', or French'.
# These should be converted to 3-character codes in line with this documentation:
#  http://www.loc.gov/marc/languages/language_code.html
# Values that aren't mapped will be copied as-is into the response, but without 
# the ISO639-2 attribute.
#
###################################################################################

#$c->{plugins}->{"OAI_UKETD_DC"}->{params}->{lang_to_3char} = {
#	en => "eng",
#	fr => "fre",
#	'English' => 'eng',
#};


###################################################################################
# 
# contributor_type_thesis_advisor
# The contributor type to include as a supervisor 
#
###################################################################################

# $c->{plugins}->{"OAI_UKETD_DC"}->{params}->{contributor_type_thesis_advisor} = "http://www.loc.gov/loc.terms/relators/THS";




###################################################################################


###################################################################################
###
###  The following functions can be overwritten to suit repository configuration
###    but will require some programming knowledge to get them working
###
### - creator_and_orcid
### - advisor_and_orcid
### - funder_and_project
### - doi
### - departments
###
### The outline below can be used as a starting point to write any mappings
### your repository may need.
### It may be useful to refer to the default methods in 
### EPrints::Plugin::Export::OAI_UKETD_DC_2017 
###
### There are two 'internal' methods that format DOIs, ORCIDs in the way EThOS
### would like to receive them:
### my $orcid = _format_orcid( $creator->{orcid} );
### my $doi = _format_doi( $eprint->value( "doi" ) );
### If the value passed to the _format_orcid method doesn't look like an orcid, it 
### is returned as-is whereas if the value passed to _format_doi doesn't match the 
### expected format, nothing is returned.
###
###################################################################################

#$c->{plugins}->{"OAI_UKETD_DC"}->{params}->{creator_and_orcid} = sub {
#	my( $plugin, $eprint ) = @_;
#
#	my @returns = ();
#	# do something to get values
#	# push @returns, [ "elementName", "value", "namespace", { "attr1" => "value1", "attr2" => "value2", } ];
#	return @returns;
#};


###################################################################################


###################################################################################
###
### The following setting has been added to allow an extra attribute to be added
### to some author identifier elements - which can be used for both the author, 
### and the supervisor's ORCID (or ISNI).
###
### The BL may choose to use this in the future, until then, it's probably best
### to leave it turned off!
###
###################################################################################
#
# $c->{plugins}->{"OAI_UKETD_DC"}->{params}->{add_attributes_to_advisor_authoridentifier} = 0;
# $c->{plugins}->{"OAI_UKETD_DC"}->{params}->{advisor_authoridentifier_attributes} = {
#	rel => "advisor",
# };
#
###################################################################################
