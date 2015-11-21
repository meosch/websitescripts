#! /bin/bash
# Move the Modules, Libraries and Themes that we downloaded with the 
# Wetkit distribution into the normal Drupal directories, as we do not 
# want to manage them with the Wetkit profile.
#
# We are forced to do it this way so that the modules can be enabled later during the installation. The profile will only download the files into its subdirectories. However if we make a separate make file the wetkit install will abort as the dependencies files are missing. So instead we download them with the wetkit files in their own meos subdirectories then move them to the default install locations in /sites/all/.  20150521 FJH

# Change the variables below to match your situation. 
# $distroname should be the same as the distribution machine name.
# This will be the name of the folder in the profiles directory.
# $ourstufffolder is the name of the subfolder that you will put your 
# modules, themes and libraries into so that they can be copied.
# You should do this in your .make file like this:
# projects[project_name][subdir] = "ourstufffolder/contrib"
# where ourstufffolder is the name of the subfolder that your 
# non-profile  modules or themes will land in.
# Libraries are a little different and look like this:
# libraries[library_name][destination] = "libraries/ourstufffolder/library_name"
# Replace project_name and library_name with the name of the project you are adding.
# These variables will be used to create the path is the following way:
# profiles/$distroname/modules, themes, or libraries/$ourstufffolder/
# 20150521 - FJH Frederick Henderson
PS4=':${LINENO} + '
#set -x

distroname="wetkit"
ourstufffolder="meos"
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
  if [ ! -z $drupalrootpath ] ; then
    cd $drupalrootpath
  else
     drupalrootpath=$pwd
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
result=$(grep -c [Dd]rupal index.php | wc -l 2> /dev/null )
if [ ! $result -gt 0 ]; then
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
  echo -e -n "Should I move the MEOS files to the normal Drupal location? [y/N] "
  read -r response
response=${response,,}    # tolower
}

move(){
ourmodulespath=${drupalrootpath}/profiles/$distroname/modules/$ourstufffolder/*
ourthemespath=${drupalrootpath}/profiles/$distroname/themes/$ourstufffolder/*
ourlibrariespath=${drupalrootpath}/profiles/$distroname/libraries/$ourstufffolder/*
if [[ $response =~ ^(yes|y)$ || $yes = 1 ]]; then
  # Modules
  if [ -d  $ourmodulespath ]; then
    echo "Moving modules . . ."
    mv ${ourmodulespath}  sites/all/modules/contrib/
  else
    echo "No modules found, skipping!"
  fi

  # Themes
  if [ -d  $ourthemespath ]; then
    echo "Moving themes . . ."
    mv ${ourthemespath}  sites/all/themes/
  else
    echo "No themes found, skipping!"
  fi

  # Libraries
  if [ -d  $ourlibrariespath ]; then
    echo "Moving libraries . . ."
    mv ${ourlibrariespath}  sites/all/libraries/
  else
    echo "No libraries found, skipping!"
  fi
else
exit
fi
}
finished(){
  echo "All done moving files."
}

### MAIN PROGRAMM ###

if [ $yes = 1 ]; then 
switchdirctoryifgiven
areweinadrupalwebroot
move
else
switchdirctoryifgiven
areweinadrupalwebroot
informuser
notwhatyouwanted
moveyesno
move
finished
fi




