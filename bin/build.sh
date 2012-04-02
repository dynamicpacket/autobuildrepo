#!/bin/bash

# get some globals
DATE=`date +%Y-%m-%d`
DATEHMS=`date +%H:%M:%S`

# env variables we need set before we're executed
required=("WORKDIR" "BLDKEY" "BLD64" "BLD32" "OUTDIR" "BLDREV" "BLDNAME" "BLDAUTHOR" "BLDEMAIL")

# check for required variables
for i in "${required[@]}"
do
if [ -z "${!i}" ] ; then
	echo "ERROR: \$$i (env var) not set"
	exit 1
else
	echo "Checking for \$$i (${!i})"
fi	
done

# set some stuff of rebuild
DEBFULLNAME=$BLDAUTHOR
DEBEMAIL=$BLDEMAIL
EMAIL=$BLDEMAIL

# name of deb manifest
DEBMANIFEST=$DATE"-"$BLDREV".deb.list"

# enter workdir (dir with source)
echo "Moving to '$WORKDIR'"
cd $WORKDIR

# always build/try
if [ 1 -gt 0 ]; then 

	# save original changelog
	cp -v $WORKDIR/debian/changelog $WORKDIR/../debian.changelog.orig
		
	# add build into to changelog
DEBFULLNAME=$BLDAUTHOR \
DEBEMAIL=$BLDEMAIL \
EMAIL=$BLDEMAIL \
	debchange -l-$BLDREV "$BLDNAME - REV $BLDREV - $DATE @ $DATEHMS"

	# touch deb.list
	rm -f ../$DEBMANIFEST
	touch ../$DEBMANIFEST

# build 64bit? (this assumes current machine is 64bit)
if [ $BLD64 -gt 0 ]; then 
	# build debs
	debuild -i -b -us -uc
	# append deb list to list file
	find ../ -name *.deb | sed 's/^\.*\/*//g' >> ../$DEBMANIFEST
	# make sure built cache dir exists
	mkdir -p ../built
	# copy debs to output dir
	cp ../*.deb $OUTDIR
	# move debs into built cache dir
	mv ../*.deb ../built/
fi

# build 32bit? (assumes pebuilder is installed and libs exist)
if [ $BLD32 -gt 0 ]; then 
	ARCH=i386 pdebuild 
	# append deb list to list file
	find /var/cache/pbuilder/squeeze-i386/result/ -name *.deb | sed 's/\.*\/*var\/cache\/pbuilder\/squeeze-i386\/result\/*//g' >> ../$DEBMANIFEST
	# make sure built cache dir exists
	mkdir -p ../built
	# copy debs to output dir
	cp /var/cache/pbuilder/squeeze-i386/result/*.deb $OUTDIR
	# move debs into built cache dir
	mv /var/cache/pbuilder/squeeze-i386/result/*.deb ../built/
fi

	echo "Copy change log to '$OUTDIR'"
	# copy change log to outdir
	cp -v $WORKDIR/debian/changelog $OUTDIR
	
	echo "Revert change log as '$WORKDIR/debian/changelog'"
	# revert to original changelog
	cp -v $WORKDIR/../debian.changelog.orig $WORKDIR/debian/changelog
	# delete saved changelog
	rm $WORKDIR/../debian.changelog.orig
	
	# go up one dir to get debs	
	cd ../
	
	# sort deb manifest list
	sort -o $DEBMANIFEST $DEBMANIFEST
	
	# copy deb manifest into outdir
	cp $DEBMANIFEST $OUTDIR/deb.list

# check for build
DEBCNT=`wc -l $DEBMANIFEST | awk '{ print $1 }'`
if [ $DEBCNT -lt 1 ]; then 
	exit 1
fi	
	
	# show packages on screen
	cat $DEBMANIFEST 

fi

exit 0
