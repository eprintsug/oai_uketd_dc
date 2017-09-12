# UKETD_DC OAI-PMH update
The [UKETD_DC specification](http://ethostoolkit.cranfield.ac.uk/tiki-index.php?page=The+EThOS+UKETD_DC+application+profile) was updated in March 2017. This plugin updates EPrints to enable more data to be mapped into the UKETD_DC metadata profile.

Many of the fields that are now present in the UKETD_DC profile may have been added to an EPrints repository as a local modification. The new plugin has a default mapping for a lot of the data, but also allows for some information to be mapped in a customised way via a configuration file.

__If any customisations have been made to your UKETD_DC output, please understand (at a technical level) this plugin before installing it.__

As a minimum, you should check what thesis types your repository is configured to support (e.g. PhD, EngD, MPhil), and make sure these match (i) the range of quialifications your insitution actually awards (and/or awarded), and (ii) make sure they are mapped in the configuration file correctly (see comments in the config file for more details).

More recent versions of EPrints have both a [`thesis_type` and a `thesis_name` field](https://github.com/eprints/eprints/blob/3.3/lib/defaultcfg/cfg.d/eprint_fields.pl#L267-L290). These values will be used in preference to mapping values e.g. from 'phd' to 'doctoral'. If you are unsure whether you have both field, create the maps anyway!


```
$c->{plugins}->{"Export::OAI_UKETD_DC_2017"}->{params}->{thesis_type_to_qualname} =  {
    phd      => "Ph.D.",
    engd     => "Eng.D.",
    edd      => "Ed.D.",
    dclinpsy => "D.Clin.Psy.",
    md       => "M.D.",
    mphil    => "M.Phil.",
    mres     => "M.Res.",
    ma       => "M.A.",
    msc      => "M.Sc.",
    llm      => "L.L.M.",
};

$c->{plugins}->{"Export::OAI_UKETD_DC_2017"}->{params}->{thesis_type_to_quallevel} =  {
    phd      => "doctoral",
    engd     => "doctoral",
    edd      => "doctoral",
    dclinpsy => "doctoral",
    md       => "doctoral",
    mphil    => "masters",
    mres     => 'masters',
    ma       => 'masters',
    msc      => 'masters',
    llm      => 'masters',
};

```

NB If the value you are mapping includes non-alphanumerical characters, you may need to quote them e.g. `'abc-def' => "ABC. DEF",`.


## Future versions of EPrints
The default export plugin for the UKETD_DC has been updated in the 3.3 branch of EPrints. This means that if you are running EPrints version 3.3.16 or later, this plugin is probably not needed.

At the time of writing, how this export format will be delivered in EPrints 3.4 is unknown. If you need help with this, please try the EPrints Tech list, or submit an Issue on GitHub.

## Technical details

The plugin works by:
* stopping the UKETD_DC export plugin supplied with EPrints from responding to OAI-PMH calls specifying `metadataProfile=uketd_dc`
* adding a new export plugin that is configured to respond to the `uketd_dc` profile
* by following the instructions at the top of the config file, you can make the existing export plugin respond to the `uketd_dc` profile requests, and configure the new export plugin to respons to another metadata profile e.g. `uketd_dc_2017`. This may be useful for testing.

### Main files in this plugin:

* [`lib/plugin/EPrints/Plugin/Screen/EPMC/OAI_UKETD_DC_2017.pm`](https://github.com/eprintsug/oai_uketd_dc/blob/master/lib/plugin/EPrints/Plugin/Screen/EPMC/OAI_UKETD_DC_2017.pm) this allows editing of the configuration file via the web interface, and is normally visible to repository administrators only
* [`lib/plugin/EPrints/Plugin/Export/OAI_UKETD_DC_2017.pm`](https://github.com/eprintsug/oai_uketd_dc/blob/master/lib/plugin/EPrints/Plugin/Export/OAI_UKETD_DC_2017.pm) this is the file that maps data into the metadata profile. It contains default mappings for many field, some of which can be overwritten in the configuration file.
* [`cfg/cfg.d/z_oai_uketd_dc.pl`](https://github.com/eprintsug/oai_uketd_dc/blob/master/cfg/cfg.d/z_oai_uketd_dc.pl) This file can be edited via the web interface. It contains documentation about the default mappings that can be overridden to match repository configuration. If you are non-technical, discussing this file with the technical support for your repository might be a sensible first step.

## Useful links:
* [EThOS metadata page](http://ethostoolkit.cranfield.ac.uk/tiki-index.php?page=Metadata)
* [EThOS application profile - PDF](http://ethostoolkit.cranfield.ac.uk/tiki-download_file.php?fileId=50)
* [Other EThOS downloads](http://ethostoolkit.cranfield.ac.uk/tiki-list_file_gallery.php?page=Downloads&galleryId=8)

## Acknowledgement
* This work was funded by the British Library. Many thanks to Heather Rosie and Sara Gould for their input to the process.
* The work was undertaken as part of the development of White Rose Libraries (Universities of Leeds, Sheffield and York).
* Thanks also to Alan Stiles and the Open University for testing the new plugin.

## Dedication
This plugin is dedicated to Tim Miles-Board.

In your code, you live on.

