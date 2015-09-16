#!/bin/bash
set -x
### Moves the files we do not want to change outside our webroot folder. We link this back to their normal places each time we do a distribution rebuild in distro.rebuild.sh script.  It is only needed to run this script once before the first distribution rebuild.

# What is our webroot folder called?  docroot? httpdocs? public_html?
drupalrootpath="public_html"
# END CONFIGURATION #############################
# set yes to no ;)
yes=0

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

pause(){
   read -p "$*"
}

informuser(){
echo "This script should be run from the scripts directory which is in"
echo "the same folder with the  Drupal webroot folder."
echo "The name of the Drupal webroot folder can be specified on the command line."
echo "To see help use the -h switch."
echo "This Drupal webroot folder name is currently set to $drupalrootpath"
echo "This script will move site specific files (.htaccess, robots.txt, sites)"
echo "outside the Drupal webroot folders and then create links to them."
echo "This is a helper script when setting up a new site with a Drupal"
echo "distribution and / or a git repository. It is only need to run this"
echo "the script once to for the initial setup."
echo " "
}
areweinafolderwithdrupalwebroot(){
if [ ! -f "${drupalrootpath}/index.php" ] ; then
grep ${drupalrootpath}/[Dd]rupal index.php 2> /dev/null
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
  echo -e -n "Should I move the site specific files outside the webroot, ${drupalrootpath}? [y/N] "
  read -r response
response=${response,,}    # tolower
}

moveandlink(){
for movethis in ".htaccess" "robots.txt" "sites"
do
# Check if  the "file" is already a link. 
  if [ ! -L "../${drupalrootpath}/${movethis}" ]; then
# Move file or folder outside webroot
  	echo "Moving ${movethis} outside webroot"
    mv ../${drupalrootpath}/${movethis} ../
# Linking our file or folder to their new location
    echo "Creating symlink for  ${movethis} in ${drupalrootpath}"
    ln -st ../${drupalrootpath} ../${movethis}
  else
    echo "${movethis} is already a link and will not be moved or linked"
  fi
done


}
finished(){
  echo "All done moving files."
}

### MAIN PROGRAMM ###

if [ $yes = 1 ]; then 
areweinafolderwithdrupalwebroot
moveandlink
else
areweinafolderwithdrupalwebroot
informuser
notwhatyouwanted
moveyesno
moveandlink
finished
fi
