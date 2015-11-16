#!/bin/bash
  
# Make sure user running script is root.
if [[ $EUID -ne 0 ]]; then
  echo -e "\nThis script must be run as root.\n";
  exit;
fi

if [[ `uname -m | egrep -io "(i[36]86)" | uniq` ]]; then 
  arch="32";
  echo -e "\nSystem: ${arch}bit.\n";
else
  arch="64";
  echo -e "\nSystem: ${arch}bit.\n";
fi

distro=$(lsb_release -irs)
export distro=$distro
echo -e "\nDistro: ${distro}.\n"

# Get the current shell
shell=$(echo $SHELL | awk '{gsub(/\//, " "); print $2}')	
export shell=$shell

# Get the current logged in users name
user=$(users | awk '{print $1}')
export user=$user;
echo -e "\nUsername: ${user}.\n";

for i in pacman dpkg yum emerge aptitude; do
  if [[ `$i --help 2> /dev/null` ]]; then
    if [[ $i == "dpkg" || $i == "aptitude" ]]; then
      alt="apt-get"
    fi
    pkg_manager=$i;
    break;
  fi
done

#if [[ $(cat `pwd`/build.sh | egrep -o "\#${alt}" | wc -l) > 1 ]]; then
#  echo -e "\n\n!!!!!!!!! Please uncomment the install lines inside of $pkg_manager function before you continue !!!!!!!!!!\n\n";
#  exit;
#fi

function buildYoutubeDL() {
  echo -e "\nUnpacking youtube-dl source.\n" && sleep 1
  tar -xzvf youtube-dl.tar.gz
  echo -e "Attempting to build youtube-dl" && sleep 1;
  cd `pwd`/youtube-dl/
  echo -e "\nconfiguring\n" && sleep 1 && make
  echo -e "\nInstalling youtube-dl\n" && sleep 1 && make install 2> /dev/null
  youtube-dl -U
  echo -e "\nYoutube-dl was succesfully installed.\n"
};

function dpkg() {
echo -e "The follwing software will be installed: \n" 

echo -n "Would you like to contine[Y/n]: "
read answer

case $answer in 
  "yes"|"y"|"Y"|"YES")
    echo -e "\nInstalling the necessary software/packages.\n";
    #apt-get --force-yes --yes install ruby-dev
    #apt-get --force-yes --yes install ruby1.9.3
    #apt-get --force-yes --yes install libglib2.0-0
    #apt-get --force-yes --yes install libmagickwand-dev
    #apt-get --force-yes --yes install pandoc
    #apt-get remove youtube-dl && echo -e "\nRemoved system package: youtube-dl\n"
    #buildYoutubeDL || echo -e "\n!!!!!!!!! Sorry but youtube-dl could not be built. You must build and install before you continue !!!!!!!!!!\n";
    ;;
  *)
    echo -e "\n\nQuiting now.\n\n";
    exit;
    ;;
esac

};

function yum() {
echo -e "The follwing software will be installed: \n" 

echo -n "Would you like to contine[Y/n]: "
read answer

case $answer in
  "yes"|"y"|"Y"|"YES")
    echo -e "\nInstalling the necessary software/packages.\n";
    #yum -y install ruby1.9.3
    #yum -y install ruby-devel
    #yum -y install glib2-devel
    #yum -y install ImageMagick-devel
    #yum -y install pandoc
    #yum -R youtube-dl
    #buildYoutubeDL || echo -e "\n!!!!!!!!! Sorry but youtube-dl could not be built. You must build and install before you continue !!!!!!!!!!\n";
    ;;
  *)
    echo -e "\n\nQuiting now.\n\n";
    exit;
    ;;
esac

};

case $shell in
  "bash")
    echo -e "\nShell: Bash.\n"
    # Do other stuff here.
    ;;
  "zsh")
    echo -e "\nShell: Zsh.\n"
    # Do other stuff here.
    ;;
  "ksh")
    echo -e "\nShell: Ksh.\n"
    # Do other stuff here.
    ;;
  "sh")
    echo -e "\nShell: Sh.\n"
    # Do other stuff here.
    ;;
  "csh")
    echo -e "\nShell: Csh.\n"
  # Do other stuff here.
  ;;
esac


case $pkg_manager in

  dpkg)
    echo -e "\nPackage Manager: dpkg.\n";
    dpkg;
  ;;
  pacman)
    echo -e "\nPackage Manager: pacman.\n";
    pacman;
  ;;
  emerge)
    echo -e "\nPackage Manager: emerge.\n";
    emerge;
  ;;
  yum)
    echo -e "\nPackage Manager: yum.\n";
    yum;
  ;;
  aptitude)
    echo -e "\nPackage Manager: aptitude.\n";
    aptitude;
  ;;
esac

bundle install

mv youtube_dl-gtk.rb youtube_dl-gtk
chmod a+rx youtube_dl-gtk
cp youtube_dl-gtk /usr/local/bin/
