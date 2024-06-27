#!/bin/bash

#define log file
log_file="manage_users.log"
#a func to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $log_file
}

create_user() {
    username=$1
    group=$2
    permissions=$3

    # Check if group exists, if not create it
    if ! grep -q "^$group:" /etc/group; then
        sudo groupadd $group
        log_message "Group $group created."
    fi

    #create user
    sudo useradd -m -g $group $username
    log_message "User $username created and assigned to group $group."

    #Set perms
    sudo chmod $permissions /home/$username
    log_message "Permissions set for $username's home directory."
    sudo mkdir /home/$username/projects
    echo "Welcome, $username! some intro message here." | sudo tee /home/$username/projects/README.md > /dev/null
    sudo chown -R $username:$group /home/$username/projects
    log_message "Projects directory and README.md created for $username."
}

interactive_mode() {
    while true; do
        echo "Choose an option: add, delete, modify, exit"
        read option
        case $option in
            add)
                echo "Enter username, group, permissions (comma-separated):"
                read input
                IFS=',' read -r username group permissions <<< "$input"
                create_user $username $group $permissions
                ;;
            delete)
                echo "Enter username to delete:"
                read username
                userdel -r $username
                log_message "User $username deleted."
                ;;
            modify)
                echo "Enter username to modify, followed by new group and permissions (comma-separated):"
                read input
                IFS=',' read -r username group permissions <<< "$input"
                sudo usermod -g $group $username
                sudo chmod $permissions /home/$username
                log_message "User $username modified."
                ;;
            exit)
                break
                ;;
            *)
                echo "Invalid option."
                ;;
        esac
    done
}

#script run mode
input="usernames.csv" 
if [ "$1" == "-i" ]; then
    interactive_mode
else
    if [ -f "$input" ]; then
        while IFS=',' read -r username group permissions; do
            create_user $username $group $permissions
        done < "$input"
    else
        echo "Input file not found."
        exit 1
    fi
fi