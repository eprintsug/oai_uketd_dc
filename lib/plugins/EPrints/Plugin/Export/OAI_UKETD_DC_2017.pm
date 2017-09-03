=head1 NAME

EPrints::Plugin::Export::OAI_UKETD_DC_2017

=cut

package EPrints::Plugin::Export::OAI_UKETD_DC_2017;


######################################################################
#
# 2017-07-28 This file is based on commit 561b899:
# https://github.com/eprints/eprints/blob/561b899aac6eff99d9612afd7510892fa23e52a4/perl_lib/EPrints/Plugin/Export/OAI_UKETD_DC.pm
#
######################################################################
#
#
######################################################################
# Copyright (C) British Library Board, St. Pancras, UK
#
# Author: Steve Carr, British Library
# Email: stephen.carr@bl.uk
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
######################################################################

use EPrints::Plugin::Export;

@ISA = ( "EPrints::Plugin::Export" );

use strict;

=head2 Default options

The following default values can be overridden in the archive configuration using plugin parameters e.g.:

  $c->{plugins}->{"Export::OAI_UKETD_DC_2017"}->{params}->{metadataPrefix} = "uketd_dc_2017";

or

  $c->{plugins}->{"Export::OAI_UKETD_DC_2017"}->{params}->{advisor_and_orcid} = sub {
    my( $plugin, $eprint ) = @_;
    ...
    return @stuff
  };


=cut

my %DEFAULT;

=over

=item thesis_type_to_qualname

Maps 'short' values to proper ones e.g. 'phd' to 'Ph.D.', or 'dclinpsy' to 'D.Clin.Psy.'.

=cut


# map default thesis_type values to appropriate
# qualificationname
# can be overridden at archive level eg.
# $c->{plugins}->{"Export::OAI_UKETD_DC_2017"}->{params}->{thesis_type_to_qualname} = { .. };
$DEFAULT{thesis_type_to_qualname} = {
	phd => "Ph.D.",
	engd => "Eng.D.",
	edd => "Ed.D.",
	dclinpsy => "D.Clin.Psy",
	mphil => "M.Phil",
};


=item thesis_type_to_quallevel

Maps thesis type to a level 'Masters' or 'Doctoral'.
In more recent EPrints configuration there are two fields, 'thesis_name' (e.g. phd, end.d) 
and 'thesis_type' (masters, doctoral). If both fields exist, this is not used.

=cut

# map default thesis_type values to appropriate
# qualificationlevel
# can be overridden at archive level eg.
# $c->{plugins}->{"Export::OAI_UKETD_DC_2017"}->{params}->{thesis_type_to_quallevel} = { .. };
$DEFAULT{thesis_type_to_quallevel} = {
	phd => "doctoral",
	engd => "doctoral",
	edd => "doctoral",
	dclinpsy => "doctoral",
	mphil => "doctoral",
};


=item contributor_type_thesis_advisor

If the 'contributor' field is being used, which contributor_type should be used to match
thesis advisors.

=cut

# default contributor_type that identifies a thesis advisor
# can be overridden at archive level eg.
# $c->{plugins}->{"Export::OAI_UKETD_DC_2017"}->{params}->{contributor_type_thesis_advisor} = "advisor";
$DEFAULT{contributor_type_thesis_advisor} = "http://www.loc.gov/loc.terms/relators/THS";

=item creator_and_orcid (function)

Looks for orcids in a subfield called 'orcid' by default.
Returns arrays for author and orcid if present.

=item advisor_and_orcid (function)

Looks for advisors in 'advisor' and 'contributor' fields.
Looks for orcids in contributor subfield 'orcid' by default.


=item funder_and_project (function)

If the RIOXX2 plugin is installed it will return the 'rioxx2_project' value.
If this plugin is not present, it will look in the project and funder fields from the eprint.

=item doi (function)

References the doi or id_number field to find a DOI for this thesis.

=item departments (function)

Looks in the default 'divisions' field for department/faculty. Can be overwritten if data is stored in another
field, or if some levels of faculty/department/school shouldn't be represented.

=cut

$DEFAULT{creator_and_orcid}  = \&creator_and_orcid;
$DEFAULT{advisor_and_orcid}  = \&advisor_and_orcid;
$DEFAULT{funder_and_project} = \&funder_and_project;
$DEFAULT{doi} = \&doi;
$DEFAULT{departments} = \&departments;

=item add_attributes_to_advisor_authoridentifier

May be used in the future to add an additional attribute to ORCID fields to distinguish between
author and supervisor ORCIds.
It is provided as a simple 0 or 1 option to change in the configuration.

=item advisor_authoridentifier_attributes

A hash of the additional attributes to add when the above value is enabled

=cut

# after discussions about linking authors/supervisors to their specific ORCIDs, this route was decided:
# 1. Initially, do no use any non-defined (i.e. not defined in the UKETD_DC profile) attributes.
# 2. Add code to the plugin so that use of the attribute could easily be enabled.
#
# The solution for this is:
# i) a flag to say whether to use the attributes or not - and comment/include this in the config file
$DEFAULT{add_attributes_to_advisor_authoridentifier} = 0;
#and
# ii) a default set of attributes - which are overridable if necessary
$DEFAULT{advisor_authoridentifier_attributes} = {
	rel => "advisor",
};

=item lang_to_3char

A map of language values (normally two-characters) to three-character country codes. By default EPrints uses ISO639-1 (2-character) 
code e.g. 'en', but the BL specification asks for ISO639-2 e.g. 'eng'.
A value that is not mapped will be added verbatim to the output.
Any values that could be used at the eprint or document level could be used e.g. to map 'English' to 'eng'.
EPrints includes the following options be default: 
https://github.com/eprints/eprints/blob/3.3/lib/defaultcfg/namedsets/languages

See: http://www.loc.gov/marc/languages/language_code.html

=cut


$DEFAULT{lang_to_3char} = {
	"aa" => "aar",	"ab" => "abk",	"ae" => "ave",	"af" => "afr",	"ak" => "aka",	"am" => "amh",
	"an" => "arg",	"ar" => "ara",	"as" => "asm",	"av" => "ava",	"ay" => "aym",	"az" => "aze",
	"ba" => "bak",	"be" => "bel",	"bg" => "bul",	"bh" => "bih",	"bi" => "bis",	"bm" => "bam",
	"bn" => "ben",	"bo" => "tib",	"br" => "bre",	"bs" => "bos",	"ca" => "cat",	"ce" => "che",
	"ch" => "cha",	"co" => "cos",	"cr" => "cre",	"cs" => "cze",	"cu" => "chu",	"cv" => "chv",	"cy" => "wel",
	"da" => "dan",	"de" => "ger",	"dv" => "div",	"dz" => "dzo",
	"ee" => "ewe",	"el" => "gre",	"en" => "eng",	"eo" => "epo",	"es" => "spa",	"et" => "est",	"eu" => "baq",
	"fa" => "per",	"ff" => "ful",	"fi" => "fin",	"fj" => "fij",	"fo" => "fao",	"fr" => "fre",	"fy" => "fry",
	"ga" => "gle",	"gd" => "gla",	"gl" => "glg",	"gn" => "grn",	"gu" => "guj",	"gv" => "glv",
	"ha" => "hau",	"he" => "heb",	"hi" => "hin",	"ho" => "hmo",	"hr" => "hrv",	"ht" => "hat",
	"hu" => "hun",	"hy" => "arm",	"hz" => "her",
	"ia" => "ina",	"id" => "ind",	"ie" => "ile",	"ig" => "ibo",	"ii" => "iii",	"ik" => "ipk",
	"io" => "ido",	"is" => "ice",	"it" => "ita",	"iu" => "iku",
	"ja" => "jpn",	"jv" => "jav",
	"ka" => "geo",	"kg" => "kon",	"ki" => "kik",	"kj" => "kua",	"kk" => "kaz",	"kl" => "kal",
	"km" => "khm",	"kn" => "kan",	"ko" => "kor",	"kr" => "kau",	"ks" => "kas",	"ku" => "kur",
	"kv" => "kom",	"kw" => "cor",	"ky" => "kir",
	"la" => "lat",	"lb" => "ltz",	"lg" => "lug",	"li" => "lim",	"ln" => "lin",	"lo" => "lao",
	"lt" => "lit",	"lu" => "lub",	"lv" => "lav",
	"mg" => "mlg",	"mh" => "mah",	"mi" => "mao",	"mk" => "mac",	"ml" => "mal",	"mn" => "mon",
	"mr" => "mar",	"ms" => "may",	"mt" => "mlt",	"my" => "bur",
	"na" => "nau",	"nb" => "nob",	"nd" => "nde",	"ne" => "nep",	"ng" => "ndo",	"nl" => "dut",
	"nn" => "nno",	"no" => "nor",	"nr" => "nbl",	"nv" => "nav",	"ny" => "nya",
	"oc" => "oci",	"oj" => "oji",	"om" => "orm",	"or" => "ori",	"os" => "oss",
	"pa" => "pan",	"pi" => "pli",	"pl" => "pol",	"ps" => "pus",	"pt" => "por",
	"qu" => "que",
	"rm" => "roh",	"rn" => "run",	"ro" => "rum",	"ru" => "rus",	"rw" => "kin",
	"sa" => "san",	"sc" => "srd",	"sd" => "snd",	"se" => "sme",	"sg" => "sag",	"si" => "sin",
	"sk" => "slo",	"sl" => "slv",	"sm" => "smo",	"sn" => "sna",	"so" => "som",	"sq" => "alb",
	"sr" => "srp",	"ss" => "ssw",	"st" => "sot",	"su" => "sun",	"sv" => "swe",	"sw" => "swa",
	"ta" => "tam",	"te" => "tel",	"tg" => "tgk",	"th" => "tha",	"ti" => "tir",	"tk" => "tuk",
	"tl" => "tgl",	"tn" => "tsn",	"to" => "ton",	"tr" => "tur",	"ts" => "tso",	"tt" => "tat",
	"tw" => "twi",	"ty" => "tah",
	"ug" => "uig",	"uk" => "ukr",	"ur" => "urd",	"uz" => "uzb",
	"ve" => "ven",	"vi" => "vie",	"vo" => "vol",
	"wa" => "wln",	"wo" => "wol",
	"xh" => "xho",
	"yi" => "yid",	"yo" => "yor",
	"za" => "zha",	"zh" => "chi",	"zh" => "chi",	"zu" => "zul"
};


=item metadataPrefix

This plugin is designed to replace (using a plugin alias) the existing export plugin.
By setting this value to something other that 'uketd_dc', and not aliasing the plugin, you can expose the
data in the new format in the OAI-PMH interface. This can be useful for testing. If the value is set in a
config file using:
  $c->{plugins}->{"Export::OAI_UKETD_DC_2017"}->{params}->{metadataPrefix} = "uketd_dc_2017";
then a URL of
  http://SERVER_NAME/cgi/oai2?verb=GetRecords&metadataPrefix=uketd_dc_2017 
will use this export format.

=cut

$DEFAULT{metadataPrefix} = 'uketd_dc';

=back

=cut


sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );

	$self->{name} = "UK ETD DC OAI Schema";
	$self->{accept} = [ 'dataobj/eprint' ];
	$self->{visible} = "";
	$self->{suffix} = ".xml";
	$self->{mimetype} = "text/xml";

	# metadataPrefix is overridable - so the profile could be enabled alongside the existing uketd_dc profile, under a different name	
	#$self->{metadataPrefix} = "uketd_dc";
	#
	$self->{xmlns} = "http://naca.central.cranfield.ac.uk/ethos-oai/2.0/";
	$self->{schemaLocation} = "http://naca.central.cranfield.ac.uk/ethos-oai/2.0/uketd_dc.xsd";

	for(qw( thesis_type_to_qualname 
		thesis_type_to_quallevel
		contributor_type_thesis_advisor
		creator_and_orcid
		advisor_and_orcid
		funder_and_project
		departments
		doi
		lang_to_3char
		add_attributes_to_advisor_authoridentifier
		advisor_authoridentifier_attributes
		metadataPrefix
	))
	{
		if( defined $self->{session} )
		{
			$self->{$_} = $self->param( $_ );
		}
		$self->{$_} = $DEFAULT{$_} if !defined $self->{$_};
	}

	return $self;
}


sub output_dataobj
{
	my( $plugin, $dataobj ) = @_;

	my $xml = $plugin->xml_dataobj( $dataobj );

	return EPrints::XML::to_string( $xml );
}




#######################################################################
#
# Steve Carr - eprints revision (standard revision in order to offer
# something other than basic dublin core - which isn't going to be enough
# to encode the complex data that we are dealing with for e-theses)
# This subroutine takes an eprint object and renders the XML DOM
# to export as the uketd_dc default format in OAI.
#
######################################################################

sub xml_dataobj
{
	my( $plugin, $eprint ) = @_;

	# we have a variety of namespaces since we're doing qualified dublin core, so we need an
	# array of references to three element arrays in our data structure
	my @etdData = $plugin->eprint_to_uketd_dc( $eprint );

	my $namespace = $plugin->{xmlns};
	my $schema = $plugin->{schemaLocation};

	# the eprint may well be null since it may not be a thesis but an article
	my $uketd_dc = $plugin->{session}->make_element(
		"uketd_dc:uketddc",
		"xmlns:dc" => "http://purl.org/dc/elements/1.1/",
		"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
		# TO DO check out that these are properly acceptable when validated
		# TO DO put in final location for our xsd and namespace - it'll probably be somewhere on ethos.ac.uk or bl.uk
		"xsi:schemaLocation" => $namespace." ".$schema,
		"xmlns:uketd_dc" => $namespace,
		"xmlns:dcterms" => "http://purl.org/dc/terms/",
		"xmlns:uketdterms" => "http://naca.central.cranfield.ac.uk/ethos-oai/terms/"
	);
	# turn the list of pairs into XML blocks (indented by 8) and add them
	# them to the ETD element.
 
	foreach( @etdData )
	{
		if(scalar @$_ < 4){
			$uketd_dc->appendChild( $plugin->{session}->render_data_element( 8, $_->[2].":".$_->[0], $_->[1] ) );
		}
		elsif( ref $_->[3] eq "HASH" ){
			# handle multiple attributes
			$uketd_dc->appendChild( $plugin->{session}->render_data_element( 8, $_->[2].":".$_->[0], $_->[1], %{$_->[3]}  ) );
		}
		else {
			# there's an attribute to add
			$uketd_dc->appendChild( $plugin->{session}->render_data_element( 8, $_->[2].":".$_->[0], $_->[1], "xsi:type"=> $_->[3]  ) );
		}
	}
	return $uketd_dc;

}

##############################################################################
#
# Steve Carr
# subroutine to create a suitable array of array refs to the two item arrays
# as per routine directly above for dublin core (dc). The only difference is that
# qualified dublin core will have additional namespaces and more elements from
# the eprint can be utilised. So we return a longer, three element array per
# array ref. This may need rethinking when we get to attributes (e.g. xsi:type="URI")
#
#
##############################################################################

sub eprint_to_uketd_dc
{
	my( $plugin, $eprint ) = @_;

	my $session = $plugin->{session};

	my @etddata = ();
	# we still want much the same dc data so include under the dc namespace
	# by putting the namespace last this won't break the simple dc rendering routine
	# above. Skip all records that aren't theses because uketd_dc is nonsensical for
	# non-thesis items.
	
	if($eprint->get_value( "type") eq "thesis" || $eprint->get_value( "type" ) eq "Thesis"){

		#function to skip rendering specific documents in the metadata
		if( $plugin->repository->can_call( "oai_uketd_dc_skip_eprint" ) )
		{
			if( $plugin->repository->call( "oai_uketd_dc_skip_eprint", $eprint ) ){
				#return (empty) array to generate a 'cannotDisseminateFormat' response
				return @etddata;
			};
		}
		
		push @etddata, [ "title", $eprint->get_value( "title" ), "dc" ]; 
		
		if( $eprint->is_set( "date" ) )
		{
			push @etddata, [ "date", $eprint->get_value( "date" ), "dc" ];
		}

		#get data from referenced field functions
		foreach(qw( creator_and_orcid advisor_and_orcid funder_and_project departments doi ))
		{
			push @etddata, &{$plugin->{$_}}( $plugin, $eprint );
		}

		if( $eprint->exists_and_set("subjects")) ##Check for existence before accessing. jy2e08
		{
			my $subjectid;
			foreach $subjectid ( @{$eprint->get_value( "subjects" )} )
			{
				my $subject = EPrints::DataObj::Subject->new( $session, $subjectid );
				# avoid problems with bad subjects
				next unless( defined $subject ); 
				push @etddata, [ "subject", EPrints::Utils::tree_to_utf8( $subject->render_description() ), "dc" ];
			}
		}
		# Steve Carr : we're using qdc, namespace dcterms, version of description - 'abstract'
		push @etddata, [ "abstract", $eprint->get_value( "abstract" ), "dcterms" ]; 
		
		# Steve Carr : theses aren't technically 'published' so we can't assume a publisher here as in original code
		if( $eprint->exists_and_set( "publisher" ) ){
			push @etddata, [ "commercial", $eprint->get_value( "publisher" ), "uketdterms" ]; 
		}
	
		my $editors = $eprint->get_value( "editors_name" );
		if( defined $editors )
		{
			foreach my $editor ( @{$editors} )
			{
				push @etddata, [ "contributor", EPrints::Utils::make_name_string( $editor ), "dc" ];
			}
		}

		## Date for discovery. For a month/day we don't have, assume 01.
		my $date = $eprint->get_value( "date" );
		if( defined $date )
		{
	        	$date =~ m/^(\d\d\d\d)(-\d\d)?/;
			my $issued = $1;
			if( defined $2 ) { $issued .= $2; }
			push @etddata, [ "issued", $issued, "dcterms" ];
		}
	

		push @etddata, [ "type", $session->get_type_name( "eprint", $eprint->get_value( "type" ) ), "dc" ];

		# The URL of the abstract page is the dcterms isreferencedby
		push @etddata, [ "isReferencedBy", $eprint->get_url(), "dcterms" ];


		my @documents = $eprint->get_all_documents();
		my $mimetypes = $session->config( "oai", "mime_types" );
		foreach( @documents )
		{
			#function to skip rendering specific documents in the metadata
			if( $plugin->repository->can_call( "oai_uketd_dc_skip_document" ) )
			{
				next if $plugin->repository->call( "oai_uketd_dc_skip_document", $_ );
			}

			my $format = $mimetypes->{$_->get_value("format")};
			$format = $_->get_value("format") unless defined $format;
			#$format = "application/octet-stream" unless defined $format;

			push @etddata, [ "identifier", $_->get_url(), "dc", "dcterms:URI" ];
			push @etddata, [ "format", $format, "dc" ] if defined $format;
			# information about extent and checksums could be added here, if they are available
			# the default eprint doesn't have a place for this but both could be generated dynamically

			# output a language, embargodate and rights element for each document where possible
			# this may be in addition to fields defined at the eprint level (see below)
			if( $_->exists_and_set( "language" ) )
			{
				my $lang = $_->get_value( "language" );
				if( defined $plugin->{lang_to_3char}{ $lang } ){
					push @etddata, [ "language", $plugin->{lang_to_3char}{ $lang }, "dc", { "xsi:type" => "dcterms:ISO639-2" } ];
				} else {
					push @etddata, [ "language", $lang, "dc"];
				}
			}
			if( $_->exists_and_set( "date_embargo" ) )
			{
				push @etddata, ["embargodate", _last_day_of_embargo( $_->get_value( "date_embargo" ) ), "uketdterms"];
			}
			if( $_->exists_and_set( "security" ) )
			{
				push @etddata, ["accessRights", $_->get_value("security"), "dcterms"];
			}
		}
	
		# Steve Carr : we're using isreferencedby for the official url splash page
		if( $eprint->exists_and_set( "official_url" ) )
		{
			push @etddata, [ "isReferencedBy", $eprint->get_value( "official_url" ), "dcterms", "dcterms:URI"];
		}

		# qualificationname = Ph.D, Ed.D, M.Phil
		if( $eprint->exists_and_set( "thesis_name" )){
			push @etddata, [ "qualificationname", $eprint->get_value( "thesis_name" ), "uketdterms"];
		}
		elsif( $eprint->exists_and_set( "thesis_type" ) )
		{
			# attempt to derive a qualificationname from thesis_type
			my $name = $eprint->get_value( "thesis_type" );
			if( defined $plugin->{thesis_type_to_qualname}{ $name } ){
				$name = $plugin->{thesis_type_to_qualname}{ $name };
			}
			push @etddata, [ "qualificationname", $name, "uketdterms"];
		}

		# qualificationlevel should be e.g. 'masters' or 'doctoral'.
		# In older EPrints configuration, the 'thesis_type' field (also referenced above) contained
		# phd, engd, mphil. These values are mapped in thesis_type_to_quallevel.
		# In newer config, the thesis_type is already the correct value.
		if( $eprint->exists_and_set( "thesis_type")){
			my $type = $eprint->get_value( "thesis_type" );
			if( defined $plugin->{thesis_type_to_quallevel}{ $type } )
			{
				$type = $plugin->{thesis_type_to_quallevel}{ $type };
			}
			push @etddata, [ "qualificationlevel", $type, "uketdterms"];
		}
		if( $eprint->exists_and_set( "institution" )){
			push @etddata, [ "institution", $eprint->get_value( "institution" ), "uketdterms"];
		}

		if( $eprint->exists_and_set( "language" )){
			my $lang = $eprint->get_value( "language" );
			if( defined $plugin->{lang_to_3char}{ $lang } ){
				push @etddata, [ "language", $plugin->{lang_to_3char}{ $lang }, "dc", { "xsi:type" => "dcterms:ISO639-2" } ];
			} else {
				push @etddata, [ "language", $lang, "dc"];
			}
		}

		if( $eprint->exists_and_set( "alt_title" )){
			push @etddata, [ "alternative", $eprint->get_value("alt_title" ), "dcterms"];
		}
		if( $eprint->exists_and_set( "checksum" )){
			push @etddata, [ "checksum", $eprint->get_value("checksum"), "uketdterms" ];
		}
		if( $eprint->exists_and_set( "date_embargo" )){
			push @etddata, ["embargodate", $eprint->get_value("date_embargo"), "uketdterms"];
		}
		if( $eprint->exists_and_set( "embargo_reason" )){
			push @etddata, ["embargo_reason", $eprint->get_value("embargo_reason"), "uketdterms"];
		}
		if( $eprint->exists_and_set( "rights" )){
			push @etddata, ["rights", $eprint->get_value("rights"), "dc"];
		}
		if( $eprint->exists_and_set( "citations" )){
			push @etddata, ["hasVersion", $eprint->get_value("citations"), "dcterms"];
		}
		if( $eprint->exists_and_set( "referencetext" )){
			push @etddata, ["references", $eprint->get_value("referencetext"), "dcterms"];
		}
		
	}
	
	return @etddata;
}

sub departments
{
	my( $plugin, $eprint ) = @_;

	my @depts;

	if( $eprint->exists_and_set( "divisions" ) )
	{
		foreach my $div_id ( @{$eprint->get_value( "divisions" )} )
                {
			my $dept = EPrints::DataObj::Subject->new( $plugin->{session}, $div_id );
                        # avoid problems with bad subjects
                        next unless( defined $dept );
                        push @depts, [ "department", EPrints::Utils::tree_to_utf8( $dept->render_description() ), "uketdterms" ];
                }
	}

	if( $eprint->exists_and_set( "department" ))
	{
		push @depts, [ "department", $eprint->get_value( "department" ), "uketdterms"];
	}

	return @depts;
}

sub doi
{
	my( $plugin, $eprint ) = @_;

	if( $eprint->exists_and_set( "doi" ) )
	{
		my $doi = _format_doi( $eprint->get_value( "doi" ) );
		if( defined $doi )
		{
			return [ "identifier", $doi, "dc", "dcterms:DOI" ];
		}
	}

	if( $eprint->exists_and_set( "id_number" ) ){
		my $doi = _format_doi( $eprint->get_value( "id_number" ) );
		if( defined $doi )
		{
			return [ "identifier", $doi, "dc", "dcterms:DOI" ];
		}
	}

	return;
}


sub creator_and_orcid
{
	my( $plugin, $eprint ) = @_;

	my @dc_creators = ();	
	my @orcids = ();	

	my $creators = $eprint->get_value( "creators" );
	if( defined $creators )
	{
		foreach my $creator ( @{$creators} )
		{
			push @dc_creators, [ "creator", EPrints::Utils::make_name_string( $creator->{name} ), "dc" ];
			if( EPrints::Utils::is_set( $creator->{orcid} ) ) 
			{
				push @orcids, [ "authoridentifier", _format_orcid( $creator->{orcid} ), "uketdterms", { "xsi:type" => "uketdterms:ORCID" }  ];
			}
		}
	}

	return @dc_creators, @orcids;
}

sub advisor_and_orcid
{
	my( $plugin, $eprint ) = @_;

	my @advisors = ();	
	my @orcids = ();	

	if( $eprint->exists_and_set( "advisor" ) )
	{
		push @advisors, [ "advisor", $eprint->get_value( "advisor" ), "uketdterms"];
	}
	# also look in contributors
	if( $eprint->exists_and_set( "contributors" ) )
	{
		foreach my $contrib ( @{ $eprint->get_value( "contributors" ) } )
		{
			next unless defined $contrib->{type} && defined $contrib->{name};
			next unless $contrib->{type} eq $plugin->{contributor_type_thesis_advisor};
			push @advisors, [ "advisor", EPrints::Utils::make_name_string( $contrib->{name} ), "uketdterms" ];
			if( EPrints::Utils::is_set( $contrib->{orcid} ) )
			{
				push @orcids, [ "authoridentifier", _format_orcid( $contrib->{orcid} ), "uketdterms", $plugin->_attributes_for_advisor_authoridentifier  ];
			}
		}
	}

	return @advisors, @orcids;
}

sub _attributes_for_advisor_authoridentifier
{
	my( $plugin ) = @_;

	# default attribute
	my $attrs = { "xsi:type" => "uketdterms:ORCID" };

	# merge extra attributes if required.
	# NB if an xsi:type is specified in advisor_authoridentifier_attributes, this will overwrite the value above.
	if( $plugin->{add_attributes_to_advisor_authoridentifier} ){
		@$attrs{ keys %{$plugin->{advisor_authoridentifier_attributes}} } = values %{$plugin->{advisor_authoridentifier_attributes}};
	}
	
	return $attrs;
}

sub funder_and_project
{
	my( $plugin, $eprint ) = @_;

	my @sponsors = ();
	my @grants = ();
	
	# rioxx2_project contains a processed representation of funders and projects.
	# if it exists, use that in preference to the more feral 'projects' and 'funders' fields.
	if( $eprint->exists_and_set( "rioxx2_project" ) )
	{

		foreach my $proj ( @{ $eprint->get_value( "rioxx2_project" ) } )
		{
			if( EPrints::Utils::is_set( $proj->{project} ) ){
				push @grants, [ "grantnumber", $proj->{project}, "uketdterms" ];
			}
			if( EPrints::Utils::is_set( $proj->{funder_name} ) ){
				push @sponsors, [ "sponsor", $proj->{funder_name}, "uketdterms" ];
			}
		}

	} else {
		if( $eprint->exists_and_set( "projects" ) )
		{
			foreach my $proj ( @{ $eprint->value( "projects" ) } )
			{
				push @grants, [ "grantnumber", $proj, "uketdterms" ];
			}	
		}

		if( $eprint->exists_and_set( "funders" ) )
		{
			foreach my $funder ( @{ $eprint->value( "funders" ) } )
			{
				push @sponsors, [ "sponsor", $funder, "uketdterms" ];
			}	
		}
	}

	# 'sponsors' is a non-standard field, but was mapped in the plugin, so is retained here
	if( $eprint->exists_and_set( "sponsors" )){
		push @sponsors, [ "sponsor", $eprint->get_value( "sponsors" ), "uketdterms"];
	}

	return @sponsors, @grants;
}

sub _format_orcid
{
	my( $orcid ) = @_;

	# guidelines want 16-characters, no hyphens or URLs.
	# This should deal with URLs or namespaced values.
	$orcid =~ s#^(?:\s*(?:https?://)?orcid\.org/|orcid:/?)?(\d{4})\-?(\d{4})\-?(\d{4})\-?(\d{3}[\d|X])$#$1$2$3$4#;

	return $orcid;
}

sub _format_doi
{
	my( $doi ) = @_;

	# advice received is that just DOI is preferred to a URL
	# logic taken from EPrints::Extras::render_possible_doi
	if( $doi =~ m!^
		(?:https?://(?:dx\.)?doi\.org/)?  # add this again later anyway
		(?:doi:?\s*)?                   # don't need any namespace stuff
		(10(\.[^./]+)+/.+)              # the actual DOI => $1
	!ix )
	{
		# just use the last part - the actual DOI.
		return $1;
	}

	return undef;
}

sub _last_day_of_embargo
{
	my( $embargo ) = @_;

	if( length $embargo == 4 )
	{
		# only year defined. Embargo is released after the end of the year.
		return $embargo .= "-12-31";
	}
	if( length $embargo == 10 )
	{
		# Full date specified - return it.
		return $embargo;
	}

	if( length $embargo == 7 )
	{
		# year and month specified.	
		my( $y, $m ) = split( /\-/, $embargo );

		my $end_day = (31,28,31,30,31,30,31,31,30,31,30,31)[$m-1]; #month is 1-based; perl array is 0-based

		#if month is not Feb, end day does not change
		return "$embargo-$end_day" if $m != 2;
	
		# else work out leap year stuff
		# year is div by 4, but not 100, but is by 400
		# unlikely for ETheses embargo expiry - but I've heard talk of '100 year embargos'...
		if ( ($y % 4 == 0) && ( $y % 100 != 0 || $y % 400 == 0 ) ) 
		{
			$end_day++;
		}

		return "$embargo-$end_day";
	}

	# if none of the cases above match, the've got something strange. Just return as-is
	return $embargo;
}
	
1;


=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2000-2011 University of Southampton.

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints L<http://www.eprints.org/>.

EPrints is free software: you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

EPrints is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints.  If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END



