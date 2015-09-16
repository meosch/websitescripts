#!/bin/bash

### Moves the files we do not want to change outside our webroot folder. We link this back to their normal places each time we do a distribution rebuild in distro.rebuild.sh script.  It is only needed to run this script once before the first distribution rebuild.

# What is our webroot folder called?  docroot? httpdocs? public_html?
webroot="public_html"
yes=0
# END CONFIGURATION #############################
function usage()
{
 echo "Usage ${0##*/}  -y -h <path>"
 echo "Where:"
 echo "-y answers yes to questions. For use in scripts."
 echo "-h displays this help info."
 echo "<path> of the drupal root to operate on."
 echo ""
}

while getopts yh option
do
  case "${option}" in
    h)
      usage
      exit 2
    ;;
    y)
      yes=1
    ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
    ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
    ;;
  esac
done
# get rid of our flag options and arguments
shift $((OPTIND-1))

# Save path if given on command lines
drupalrootpath=$1

red='\e[1;31m'
NC='\e[0m' # No Color
pwd=$(pwd)


switchdirctoryifgiven(){
  if [ -n $drupalrootpath ] ; then
    cd $drupalrootpath
  else
  directoryrunfrom=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
    drupalrootpath=$directoryrunfrom
    cd $drupalrootpath
  fi
}

pause(){
   read -p "$*"
}

informuser(){
echo "This script should be run from a Drupal webroot, but the"
echo "directory to run from can be specified on the command line."
echo "To see help use the -h switch."
echo "This script will be run in $drupalrootpath"
echo "This script will move download files (modules, libraries, themes)"
echo "into the default Drupal folders site/all/"
echo "from the profile location."
echo " "
}
areweinadrupalwebroot(){
if [ ! -f index.php ] ; then
grep [Dd]rupal index.php 2> /dev/null
if [ $? -ne 0 ]; then
echo -e "Exiting, I did not find the ${red}Drupal index.php${NC} file."
informuser
echo "Nothing more to do, exiting. Bye!"
exit
fi
fi
}
notwhatyouwanted(){
echo -e "If this is not what you want hit ${red}Ctrl + C${NC} to abort this script or press any key to continue."
pause
echo " "
}

moveyesno(){
  echo -e -n "Should I move the site specific files outside the webroot, ${webroot}? [y/N] "
  read -r response
response=${response,,}    # tolower
}

move(){

for movethis in ".htaccess" "robots.txt" "sites"
do
  if [ ! -L "../${webroot}/${movethis}" ]; then
# Move files and folders outside webroot
  	echo "Moving ${movethis} outside webroot"
    mv ../${webroot}/${movethis} ../
# Linking our files to their new locations
    echo "Symlinking ${movethis} to ${webroot}/sites"
    ln -s ../${movethis} ../${movethis}
  else
    echo "${movethis} is already a link and will not be moved or linked"
done


}
finished(){
  echo "All done moving files."
}



if [ ! -d "$webroot" ]; then
  echo "Webroot - $webroot - does not exist!"
  exit
fi

# Move files and folders outside webroot
echo "Moving .htaccess outside webroot"
mv ../${webroot}/.htaccess ../
echo "Moving robots.txt outside webroot"
mv ../${webroot}/robots.txt ../
echo "Moving sites folder outside webroot"
mv ../${webroot}/sites ../



# Linking our files to their new locations
echo "Symlinking sites directory to ${webroot}/sites"
cd ../${webroot}
#rm -rf sites
ln -s ../sites
echo "Symlinking .htaccess ${webroot}/.htaccess"
#rm .htaccess
ln -s ../.htaccess
echo "Symlinking robots.txt to ${webroot}/robots.txt"
#rm robots.txt
ln -s ../robots.txt
