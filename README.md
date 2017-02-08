# Standalone OHS Domain

This project allows us to create silently a WLS Domain as explained in detail in 
my blog at [WLS Provisioning] (https://realworlditblog.wordpress.com/2016/09/06/wls-provisioning-part-1-installation/)

The project contains 4 main folders
- bin : Utility to setup and launch the vagrant box (as defined in Vagrantfile)
- config : Where the domain configuration files are (I just bundled with and example config)
- software : Where you should put the jdk an wls instaklation files 
- vagrant : The vagrant environment
- src : The sources for the wls domain creation

I guess that the scripts are quite self explained and are all documented so I'll just note some 
important steps in order to use the scripts:

1. Download the JDK and WLS Software from Oracle edelivery site (and put them in the software folder)
2. Adjust your configurations (files in the config directory)
3. Run (using bin/run)

You can see in more detail the actions that are taken to instal the FMW software and create the domain

## Vagrant

The vagrant folder is used to provide you a quickstart to the wls domain provisioning scripts so that you can reuse them as you want.

### The box

The vagrant setup uses a custom made vagrant box that already has everything that is needed to setup any Oracle FMW software.
The box was made using the packer tool (check [OEL 7 - vbox](https://github.com/miguelcarto/packer-oel))

## More

Check my [blog](http://realworlditblog.wordpress.com "real world IT") for more tips and tricks about Oracle FMW install and administration