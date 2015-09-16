#!/bin/bash
#set -x
### Moves the files we do not want to change outside our webroot folder. We link this back to their normal places each time we do a distribution rebuild in distro.rebuild.sh script.  It is only needed to run this script once before the first distribution rebuild.

# What is our webroot folder called?  docroot? httpdocs? public_html?
webroot="public_html"
# END CONFIGURATION #############################
# set yes to no ;)
yes=0
runningscriptname=$(basename "$0")
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
echo -e "This script, ${red}${runningscriptname}${NC} should be run from the ${red}scripts${NC} directory which is in the same folder with the Drupal webroot folder."
echo "The name of the Drupal webroot folder name can be specified on the command line. The default is public_html."
echo -e "To see help use the ${red}-h${NC} switch."
echo -e "The Drupal webroot folder name is currently set to ${red}$drupalrootpath${NC}"
echo -e "This script will move site specific file and folders (${red}.htaccess, robots.txt, sites${NC}) outside the Drupal webroot folders and then create links to them."
echo "This is a helper script to be used when setting up a new site with a Drupal distribution and/or a git repository. "
echo "It is only need to run this script once for the initial setup."
echo "If links are found instead of the files and folders to move, the script will assume you have run it before and not repeat the process."
echo " "
}
setdrupalwebroot(){
  if [ -z $drupalrootpath ] ; then
     drupalrootpath=$webroot
  fi
}
areweinafolderwithdrupalwebroot(){
if [ ! -f "../${drupalrootpath}/index.php" ] ; then
grep [Dd]rupal ../${drupalrootpath}/index.php 2> /dev/null
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
  echo -e -n "Should I move the site specific files outside the webroot, ${red}${drupalrootpath}${NC}? ${red}[y/N]${NC} "
  read -r response
response=${response,,}    # tolower
  if [[ $response !=  "y" && $response != "Y"  && $response != "yes" && $response != "Yes" ]]; then
    exit
  fi
}

moveandlink(){
for movethis in ".htaccess" "robots.txt" "sites"
do
# Check if  the "file" is already a link. 
  if [ ! -L "../${drupalrootpath}/${movethis}" ]; then
# Move file or folder outside webroot
    echo ""
  	echo -e "Moving ${red}${movethis}${NC} outside webroot"
    mv ../${drupalrootpath}/${movethis} ../
# Linking our file or folder to their new location
    echo -e "Creating symlink for ${red}${movethis}${NC} in ${drupalrootpath}"
    ln -st ../${drupalrootpath} ../${movethis}
  else
    echo -e "${red}${movethis}${NC} is already a link and will not be moved or linked"
  fi
done


}
finished(){
  echo "All done moving files."
}

### MAIN PROGRAMM ###

if [ $yes = 1 ]; then
setdrupalwebroot
areweinafolderwithdrupalwebroot
moveandlink
else
setdrupalwebroot
areweinafolderwithdrupalwebroot
informuser
notwhatyouwanted
moveyesno
moveandlink
finished
fi
