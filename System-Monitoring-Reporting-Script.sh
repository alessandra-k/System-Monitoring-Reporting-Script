#!/bin/bash

# Author: Alessandra Prunzel Kittlaus
# Student Number: 041096703
# Course: CST8102 Operating System Fundamentals
# Lab Section: 340
# Script File: system_report.sh
# Date Completed: December 06,2023
# Description: This script provides system monitoring and reporting functionalities, including generating system reports, 
# checking CPU load, memory usage, and disk usage, creating log files, and creating compressed archives.

# Purpose: Collect and display general system information.
# Algorithm:
# 1. Print a message indicating system report generation.
# 2. Print date and time.
# 3. Print hostname, operating system, and kernel version.
# 4. Print CPU model name.
# 5. Use the free -m command to gather details about system memory.
# 6. Print total, used, and free disk space.
# 7. Call functions to check CPU load, memory usage, and disk usage.
function system_details() {
    echo "Generating System Report..."
    echo "Date and Time: $(date)"
    echo "System Information:"
    echo "Hostname: $(hostname)"
    echo "Operating System: $(uname -s)"
    echo "Kernel Version: $(uname -r)"
    echo "CPU Information:"
    echo "$(lscpu | grep 'Model name')"
    memory=$(free -m)
    total_memory=$(echo "$memory" | sed -n '2s/ \+/ /gp' | cut -d ' ' -f 2)
    echo "Total memory: $total_memory MB"
    free_memory=$(echo "$memory" | sed -n '2s/ \+/ /gp' | cut -d ' ' -f 4)
    echo "Free memory: $free_memory MB"
    disk_usage=$(df -h /)
    total=$(echo "$disk_usage" | sed -n '2s/ \+/ /gp' | cut -d ' ' -f 2)
    used=$(echo "$disk_usage" | sed -n '2s/ \+/ /gp' | cut -d ' ' -f 3)
    free=$(echo "$disk_usage" | sed -n '2s/ \+/ /gp' | cut -d ' ' -f 4)
    echo "Disk usage information:"
    echo "Total: $total; Used: $used; Free: $free"
    echo ""
    check_cpu_load
    check_memory_usage
    check_disk_usage
    echo ""
}

# Purpose: Check the current CPU load and display a warning or success message.
# Algorithm:
# 1. Set the threshold for acceptable CPU load to 80%.
# 2. Get the system load average using the `uptime` command.
# 3. Extract the load average value.
# 4. Remove any trailing comma and spaces.
# 5. Calculate the load percentage.
# 6. Compare the load percentage with the threshold.
# 7. If the load is above the threshold, print a warning message.
# 8. If the load is within the threshold, print a success message.
function check_cpu_load() {
    threshold_cpu=80
    load_average=$(uptime | awk -F'average:' '{print $2}' | awk '{print $1}' | cut -d, -f1 | sed 's/ //g')
    load_percent=$(echo "$load_average * 100" | bc -l)
    
    if (( $(echo "$load_percent > $threshold_cpu" | bc -l) )); then
        echo "WARNING: CPU load is above acceptable limits ($load_average%)"
    else
        echo "SUCCESS: CPU load is within acceptable limits ($load_average%)"
    fi
}

# Purpose: Calculate the percentage of memory usage and display a warning or success message.
# Algorithm:
# 1. Set the threshold for acceptable memory usage to 50%.
# 2. Use the `free -m` command to get memory details.
# 3. Extract total and used memory using `sed` and `cut`.
# 4. Calculate memory usage percentage.
# 5. Compare the memory usage percentage with the threshold.
# 6. If memory usage exceeds the threshold, print a warning message.
# 7. If memory usage is within the threshold, print a success message.
function check_memory_usage() {
    threshold_memory=50
    total_memory_check=$(free -m | sed -n '2s/ \+/ /gp' | cut -d ' ' -f 2)
    used_memory_check=$(free -m | sed -n '2s/ \+/ /gp' | cut -d ' ' -f 3)
    memory_usage_percent=$(echo "($used_memory_check * 100) / $total_memory_check" | bc)

    if (( $memory_usage_percent > $threshold_memory )); then
        echo "WARNING: Memory usage is above acceptable limits ($memory_usage_percent%)"
    else
        echo "SUCCESS: Memory usage is within acceptable limits ($memory_usage_percent%)"
    fi
}


# Purpose: heck the disk usage of the root filesystem (/) and display a warning or success message.
# Algorithm:
# 1. Set the threshold for acceptable disk usage to 70%.
# 2. Use the `df -h /` command to get disk usage details for the root filesystem.
# 3. Extract disk usage percentage using `sed` and `cut`.
# 4. Remove the percentage sign from the extracted value.
# 5. Compare the disk usage percentage with the threshold.
# 6. If disk usage exceeds the threshold, print a warning message.
# 7. If disk usage is within the threshold, print a success message.
function check_disk_usage() {
    threshold_disk=70
    disk_usage_percent=$(df -h / | sed -n '2s/ \+/ /gp' | cut -d ' ' -f 5 | sed 's/%//')

    if (( $(echo "$disk_usage_percent > $threshold_disk" | bc -l) )); then
        echo "WARNING: Disk usage is above acceptable limits ($disk_usage_percent%)"
    else
        echo "SUCCESS: Disk usage is within acceptable limits ($disk_usage_percent%)"
    fi
}

# Purpose: Create a log file named "system_report.log".
# Algorithm:
# 1. Use the `>` operator to create an empty log file named "system_report.log".
function create_log_file() {
    > system_report.log
}
 
# Purpose: Append system report details to the log file.
# Algorithm:
# 1. Call the system_details function to generate a system report.
# 2. Use the `>>` operator to append the generated system report to the log file named "system_report.log".
function append_to_log_file() {
    system_details >> system_report.log
}

# Purpose: Create a compressed archive file containing the "system_report.log".
# Algorithm:
# 1. Check if the log file "system_report.log" exists and is not empty using the [ -s ] test.
# 2. If the log file exists and is not empty:
#    a. Create a compressed archive named "system_report.tar.gz" containing the log file.
#    b. Print a success message indicating that the archive was created successfully.
# 3. If the log file does not exist or is empty:
#    a. Print an error message indicating the issue.
#    b. Create a new log file using the create_log_file function.
#    c. Append system report details to the log file using the append_to_log_file function.
#    d. Create a compressed archive named "system_report.tar.gz" containing the log file.
#    e. Generate a new system report using the system_details function.
#    f. Print a success message indicating that the archive was created successfully.
function create_archive() {
    if [ -s "system_report.log" ]; then
        tar -czf system_report.tar.gz system_report.log
        echo "Archive created successfully."
    else
        echo "Error: Log file does not exist or is empty. Generating a new report before creating the archive."
        create_log_file
        append_to_log_file
        tar -czf system_report.tar.gz system_report.log
		system_details
        echo "Archive created successfully."
		echo ""
    fi
}

# Purpose: Continuously present a menu for system monitoring and reporting options until user press 3.
# Algorithm:
# 1. Start an infinite loop using 'while true'.
# 2. Print a header for the system monitoring and reporting menu.
# 3. Present menu options:
#    a. Generate a System Report (Option 1)
#    b. Create an Archive (Option 2)
#    c. Exit the script (Option 3)
# 4. Prompt the user to enter their choice.
# 5. Read the user's choice into the 'choice' variable.
# 6. Use a 'case' statement to perform actions based on the user's choice:
#    a. If the user chooses Option 1:
#       - Call the system_details function to generate a system report.
#       - Call the append_to_log_file function to append system report details to the log file.
#    b. If the user chooses Option 2:
#       - Call the create_archive function to create a compressed archive containing the log file.
#    c. If the user chooses Option 3:
#       - Exit the script.
#    d. If the user chooses an invalid option:
#       - Print an error message indicating that the option is invalid.
while true; do
    echo "System Monitoring and Reporting"
    echo "+++++++++++++++++++++++++++++"
    echo "1. Generate System Report"
    echo "2. Create Archive"
    echo "3. Exit"
    echo "+++++++++++++++++++++++++++++"
    echo "Enter your choice: "

    read choice

    case $choice in
        1)
            system_details
            append_to_log_file
            ;;
        2)
            create_archive
            ;;
        3)
            exit
            ;;
        *)
            echo "Invalid option! Please choose a valid menu item."
			echo ""
            ;;
    esac
done
