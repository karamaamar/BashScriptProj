#!/bin/bash

#validate record name
validate_record_name() {
    local name=$1
    if [[ $name =~ ^[a-zA-Z0-9[:space:]]+$ ]]; then
        return 0
    else
        return 1
    fi
}

#amount validation 
validate_amount() {
    local amount=$1
    if [[ $amount =~ ^[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

#add or update a record
add_update_record() {
    local record_name=$1
    local amount=$2
    if validate_record_name "$record_name" && validate_amount "$amount"; then
        if grep -q "^$record_name," "$record_file"; then
            sed -i "s/^$record_name,.*/$record_name,$amount/" "$record_file"
            log_event "Update Success"
        else
            echo "$record_name,$amount" >> "$record_file"
            log_event "Add Success"
        fi
    else
        echo "Error: Invalid input"
        log_event "Invalid Input"
    fi
}

#delete a record
delete_record() {
    local record_name=$1
    if validate_record_name "$record_name"; then
        if grep -q "^$record_name," "$record_file"; then
            sed -i "/^$record_name,/d" "$record_file"
            log_event "Delete Success"
        else
            echo "Error: Record not found"
            log_event "Record Not Found"
        fi
    else
        echo "Error: Invalid input"
        log_event "Invalid Input"
    fi
}

#search for a record
search_record() {
    local search_term=$1
    if validate_record_name "$search_term"; then
        grep -i "$search_term" "$record_file" || echo "Error: Record not found"
        log_event "Search"
    else
        echo "Error: Invalid input"
        log_event "Invalid Input"
    fi
}

#update a record
update_record() {
    local old_name=$1
    local new_name=$2
    local amount=$3
    if validate_record_name "$old_name" && validate_record_name "$new_name" && validate_amount "$amount"; then
        if grep -q "^$old_name," "$record_file"; then
            sed -i "s/^$old_name,.*/$new_name,$amount/" "$record_file"
            log_event "Update Success"
        else
            echo "Error: Record not found"
            log_event "Record Not Found"
        fi
    else
        echo "Error: Invalid input"
        log_event "Invalid Input"
    fi
}

#print total amount of records
print_total_amount() {
    local total=$(awk -F ',' '{sum+=$2} END {print sum}' "$record_file")
    echo "Total number of records: $total"
    log_event "Print Total"
}

#print all records sorted by name
print_sorted_records() {
    sort -t ',' -k1 "$record_file" | column -t -s ','
    log_event "Print Sorted"
}

#log events
log_event() {
    local event="$1"
    echo "$(date +'%d/%m/%Y %H:%M:%S') $event" >> "$log_file"
}

# Main menu function
main_menu() {
    echo "Record Management System"
    echo "1. Add or Update a Record"
    echo "2. Delete a Record"
    echo "3. Search for a Record"
    echo "4. Update a Record"
    echo "5. Print Total Amount of Records"
    echo "6. Print Sorted Records"
    echo "7. Exit"
    read -p "Enter your choice: " choice
    case $choice in
        1) read -p "Enter record name: " name
           read -p "Enter amount: " amount
           add_update_record "$name" "$amount";;
        2) read -p "Enter record name: " name
           delete_record "$name";;
        3) read -p "Enter search term: " term
           search_record "$term";;
        4) read -p "Enter old record name: " old_name
           read -p "Enter new record name: " new_name
           read -p "Enter new amount: " new_amount
           update_record "$old_name" "$new_name" "$new_amount";;
        5) print_total_amount;;
        6) print_sorted_records;;
        7) exit;;
        *) echo "Invalid choice";;
    esac
}

# set record and log file names
record_file=$1
log_file="${record_file%.*}_log.txt"

# Main loop
while true; do
    main_menu
done
