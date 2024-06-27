#!/bin/bash

log_file="manage_users_undo.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $log_file
}

#del func
delete_user_and_group() {
    username=$1
    group=$2
    # Delete user
    sudo userdel -r $username
    log_message "User $username and their home directory deleted."

    # Check if group exists and delete it
    if grep -q "^$group:" /etc/group; then
        sudo groupdel $group
        log_message "Group $group deleted."
    else
        log_message "Group $group not found."
    fi
}

INPUT_FILE="usernames.csv" 
if [ -f "$INPUT_FILE" ]; then
    while IFS=',' read -r username group permissions; do
        delete_user_and_group $username $group
    done < "$INPUT_FILE"
else
    echo "Input file not found."
    exit 1
fi