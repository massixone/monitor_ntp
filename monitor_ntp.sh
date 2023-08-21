#!/bin/bash
#
# -*- coding:utf-8, indent=space, tabstop=4 -*-
#
#    monitor_ntp is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#   @package    monitor_ntp
#   @module     process management
#   @author     Massimo Di Primio   massimo@diprimio.com
#   @license    GNU General Public License version 3, or later
#
#  __  __                _  _                _   _  _____  ____  
# |  \/  |  ___   _ __  (_)| |_  ___   _ __ | \ | ||_   _||  _ \ 
# | |\/| | / _ \ | '_ \ | || __|/ _ \ | '__||  \| |  | |  | |_) |
# | |  | || (_) || | | || || |_| (_) || |   | |\  |  | |  |  __/ 
# |_|  |_| \___/ |_| |_||_| \__|\___/ |_|   |_| \_|  |_|  |_|    
# 

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   P R E A M B L E
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

declare mntpd_APP_VERSION="1.0.1"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   C O N F I G
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#

typeset -i mntpd_DELAY=600    # Loop delay in seconds (default: 600)
typeset -i mntpd_COUNT=1      # Number of iteractions 

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   F U N C T I O N S
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# function basename ()
# replacement for 'basename' linux command
# @ fully qualified file name
function basename () {
    TMPARG=$1
    echo ${TMPARG##*/}
}

# function dirname()
# replacement for 'dirname' linux command
function dirname() {
    TMPARG=$1
    echo ${TMPARG%/*}
}

function show_version () {
    do_echo "${APP_NAME} - Version:  ${mntpd_APP_VERSION}"
}

# function do_usage ()
# Shows usage
# @ No arguments
function do_usage () {
    
    #do_echo "${APP_NAME} - Version:  ${mntpd_APP_VERSION}"
    #show_version
    echo -en "\n***** $(basename $0)  - Version:  ${mntpd_APP_VERSION}
        usage:.\n
        -h | --help      Show this message
        -c count         Number of cycles. A value <= 0 indicates an  endless loop (default 1)
        -d seconds       Delay in seconds between loop cycle (default 600)
        -V               Show version and exit.
        "

}

# ------------------------------------------------------------
# do_echo () 
# @1  string    the message to be shown on th screen
# Writes (actually echo) the given string(s) ONLY if running
# interactively (i.e. attached terminal exists and it is
# coherent: not run by cron).
# ------------------------------------------------------------
function do_echo () {
    #if [ $TERM != 'dumb' ];then
    #      [ ${DBG_FLG} -ne 0 ] && echo -e "[`/usr/bin/basename $0`] $*"
    #fi
    echo -en "[$(basename $0)] $(date "+%Y-%m-%d %H:%M:%S") $*\n"
}

# do_exit
# Does all necessary operations to terminate the program
# @ No arguments
function do_exit () {
    do_echo "${FUNCNAME}() Program is terminating"
    kill $$
}

# mntp_restart_ntpd
# function reponsible for restarting the 'ntp' process
# @ No arguments
function mntp_restart_ntpd () {
    /etc/init.d/ntpd stop
    sleep 1    
    /etc/init.d/ntpd start
    sleep 1    
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   M A I N
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# .-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-
# BOOT UP
# .-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-
# 
#APP_NAME=$(basename $0)
APP_FILE=$(basename $0)
APP_NAME=${APP_FILE/.sh/}
APP_FOLD=$(dirname $0)
cd ${APP_FOLD}  # [ ${APP_FOLD} <> "." ] && cd ${APP_FOLD}
# [DEBUG] echo "$0 | $APP_NAME | $APP_FOLD | $(pwd)"

#
# Initialize command line options to their default values

# Check who run this command
if [ ${USER} != 'root' ]; then
    do_echo "Error! Must be 'root' to run this utility"
    do_exit
fi

# .-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-
# COMMAND LINE PARSING
# .-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-
#
# Read command line arguments
while [ $# -gt 0 ];do
    case $1 in
        '-h'|'--help')
            do_usage
            kill $$     #do_exit 0
            ;;
        '-c')
            shift 1
            mntpd_COUNT=$1
            ;;
        '-d')
            shift 1
            mntpd_DELAY=$1
            ;;
        '-V'|'--version')
            show_version
            kill $$ #exit 0
            ;;
        *)
            echo -en "\nError!. Invalid argument\n\n"
            do_usage
            kill $$
    esac
    shift 1
done

# Announce we're starting up
do_echo "App: ${APP_NAME}, Version ${mntpd_APP_VERSION}. Started as ${USER} '-c ${mntpd_COUNT} -d ${mntpd_DELAY}'"

#
# The main loop
# ================

typeset -i mylCount	#=${mntpd_COUNT}
[ ${mntpd_COUNT} -gt 0 ] && mylCount=${mntpd_COUNT}
[ ${mntpd_COUNT} -le 0 ] && mylCount=1

while true    #[[ ${mylCount} -gt 0 ]]
do
    ps -e | grep -v grep | grep ntpd$ > /dev/null
    RC=$?
    if [ ${RC} -ne 0 ]; then
        do_echo "Attempting to restart process 'ntpd'..."
        mntp_restart_ntpd
    fi

    # Check requested behaviour
    if [[ ${mylCount--} -gt 0 ]]; then
        # countles loop (loop forever)
        do_echo "Round ${mylCount--}. Going to sleep for ${mntpd_DELAY} seconds..."
        sleep ${mntpd_DELAY}   #1 # $((mntpd_DELAY*60))
    fi
    [ ${mntpd_COUNT} -gt 0 ] && ((mylCount--))
    [ ${mylCount--} -le 0 ] && kill $$
done

# end-of-file
