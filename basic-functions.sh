#! /bin/bash
#
function fullupgrade() {
    apt -y update && apt -y  upgrade && apt -y autoremove --purge
}
#
function cleanupstale() {
    dpkg -l | grep '^rc' | awk '{print $2;}' | xargs  apt -y purge
}
#
