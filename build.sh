#!/bin/bash

	if [[ $EUID -ne 0 ]]; then
		echo -e "\nThis script must be run as root.\n";
		exit;
	fi

	if [[ ! `uname -m | egrep -io "(i[36]86)" | uniq` == "" ]]; then 
		arch="32";
	else
		arch="64";
	fi

# Get the current shell
shell=$(echo $SHELL | awk '{gsub(/\//, " "); print $2}')	
export shell=$shell

# Get the current logged in users name
user=$(users | awk '{print $1}')
export user=$user

function dpkg() {
	apt-get --force-yes --yes install ruby-dev
	apt-get --force-yes --yes install ruby1.9.3
  apt-get --force-yes --yes install youtube-dl
	apt-get --force-yes --yes install libglib2.0-0
	apt-get --force-yes --yes install libmagickwand-dev
};

	case $shell in 
	  "bash")
	    echo -e "Shell: Bash"
	    # Do other stuff here.
	    ;;
	  "zsh")
	    echo -e "Shell: Zsh"
	    # Do other stuff here.
	    ;;
	  "ksh")
	    echo -e "Shell: Ksh"
	    # Do other stuff here.
	    ;;
	  "sh")
	    echo -e "Shell: Sh"
	    # Do other stuff here.
	    ;;
	  "csh")
	    echo -e "Shell: Csh"
	    # Do other stuff here.
	    ;;
	esac

bundle install

