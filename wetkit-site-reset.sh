#!/bin/bash
# Script to reset the install when building and testing installation profiles.
#set -x

distribution_name="wetkit"
domainfolder="~/neu.meos.ch/public_html/"

# END CONFIGURATION ##########################################
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
echo "This script should be run on a Drupal webroot, the"
echo "directory to run from can be specified on the command line."
echo "To see help use the -h switch."
echo "This script will be run in $drupalrootpath"
echo "This script will reset this directory with the $distribution_name distribution."
echo "It will also copy settings.php and .user.ini from the folder below web root."
echo " "
}

notwhatyouwanted(){
echo -e "If this is not what you want hit ${red}Ctrl + C${NC} to abort this script or press any key to continue."
pause
echo " "
}

resetyesno(){
  echo -e -n "Should I reset the $domainfolder with the $distribution_name distribution? [y/N] "
  read -r response
response=${response,,}    # tolower
}

reset(){

if [[ $response =~ ^(yes|y)$ || $yes = 1 ]]; then
  
 

echo "Starting reset of neu.meos.ch domain"
echo "Cleaning up."
chmod -R +w ${domainfolder}*
rm -rf ${domainfolder}*

echo "Copying files"
cp -a ~/wetkit/. ${domainfolder}
#cp -R ~/wetkit/.* ${domainfolder}
chmod -R +w ~/dev.meos.ch/public_html/*
cp ~/neu.meos.ch/settings.php ${domainfolder}sites/default/
cp ~/neu.meos.ch/.user.ini ${domainfolder}

# Fix directory permissions
echo "Fixing directory permissions . . ."
find ${domainfolder}. -type d -exec chmod 755 {} \;

#Fix file permissions
echo "Fixing file permissions . . ."
find ${domainfolder}. -type f -exec chmod 644 {} \;

echo "All done fixing permissions."
echo "All done with the reset" 
  
  
else
exit
fi
}
finished(){
  echo "All done reseting $domainfolder with $distribution_name"
}

### MAIN PROGRAMM ###

if [ $yes = 1 ]; then 
switchdirctoryifgiven
reset
else
switchdirctoryifgiven
informuser
notwhatyouwanted
resetyesno
reset
finished
fi

