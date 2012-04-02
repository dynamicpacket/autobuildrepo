AutoBuildRepo
=============

This software automatically builds debian packages from GIT or SVN repositories and copies
the resulting DEBs and manifest to a target directory. Configuration is done via a simple
file which allow for multiple projects/repositories (autobuild.conf) . Each project can also
be cross compiled to generate DEBs for 32 and 64 bit architectures. A cache is kept and
an project is only built if there has been a new commit that was not built previously. This
facilities continuous integration when running autobuildrepo via cron. 

Caveats
-------

PHP is required to run this script. Also, there is an imposed limitation where the host must
be 64 bit architecture. To cross compile 32bit, pbuilder must be installed and configured for
i386 builds.

Contributing
------------

Want to contribute? Great! Fork this repository or send patches to support  a t  dynamicpacket 
d o t  com .
