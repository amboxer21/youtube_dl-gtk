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

# Get the current shell
shell=$(echo $SHELL | awk '{gsub(/\//, " "); print $2}')	
export shell=$shell

# Get the current logged in users name
user=$(users | awk '{print $1}')
export user=$user;
echo -e "\nUsername: $user\n";

for i in dpkg pacman emerge yum aptitude; do
  if [[ `$i 2> /dev/null` ]]; then
    pkg_manager=$i;
    break;
  fi
done

function dpkg() {
  #apt-get --force-yes --yes install ruby-dev
  #apt-get --force-yes --yes install ruby1.9.3
  apt-get --force-yes --yes install youtube-dl
  apt-get --force-yes --yes install libglib2.0-0
  apt-get --force-yes --yes install libmagickwand-dev
};

function yum() {
    #yum -y install ruby1.9.3
    #yum -y install ruby-devel
    yum -y install glib2-devel
    yum -y install youtube-dl
    yum -y install ImageMagick-devel
}

case $shell in
  "bash")
    echo -e "\nShell: Bash\n"
    # Do other stuff here.
    ;;
  "zsh")
    echo -e "\nShell: Zsh\n"
    # Do other stuff here.
    ;;
  "ksh")
    echo -e "\nShell: Ksh\n"
    # Do other stuff here.
    ;;
  "sh")
    echo -e "\nShell: Sh\n"
    # Do other stuff here.
    ;;
  "csh")
    echo -e "\nShell: Csh\n"
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
  ;;
  emerge)
    echo -e "\nPackage Manager: emerge.\n";
  ;;
  yum)
    echo -e "\nPackage Manager: yum.\n";
    yum;
  ;;
  aptitude)
    echo -e "\nPackage Manager: aptitude.\n";
  ;;
esac

bundle install

