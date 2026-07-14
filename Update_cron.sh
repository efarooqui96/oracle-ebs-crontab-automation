#!/bin/bash

# Define server groups
declare -A SERVER_GROUPS
SERVER_GROUPS["1"]="oracle@tstdb01 aptst@astst01 aptst@dmztst01.doskocilmfg.com"          # TEST
SERVER_GROUPS["2"]="oracle@dbdev01 apdv@asdev01.doskocilmfg.com apdv@dmzdev01.doskocilmfg.com"  # DEV
SERVER_GROUPS["3"]="oracle@prddb applrd@prd01"                                            # PROD
SERVER_GROUPS["4"]="oracle@dbapdb01 apdba@asdbacerp01.doskocilmfg.com"  # DBA

# Prompt for group
echo "Choose a server group:"
echo "1) TEST"
echo "2) DEV"
echo "3) DBA"
echo "4) PROD"
read -p "Enter the number (1-4): " GROUP_CHOICE

# Validate group choice
if [[ -z "${SERVER_GROUPS[$GROUP_CHOICE]}" ]]; then
    echo "Invalid group number. Exiting."
    exit 1
fi

# Prompt for action
echo "Choose an action for stop/start cron jobs:"
echo "1) Remove# (Enable stop/start cron jobs)"
echo "2) Add# (Disable stop/start cron jobs)"
read -p "Enter the number (1-2): " ACTION_CHOICE

# Pattern to capture 'start' or 'stop' anywhere in the script filename
# The 'I' flag at the end of the sed commands makes this match case-insensitive
PATTERN="(stop|start).*\.sh"

# Determine sed command based on action
if [[ "$ACTION_CHOICE" == "1" ]]; then
    ACTION="Uncomment"
    # Case-insensitive match: removes the '#' from lines matching the pattern
    SED_CMD="sed -E '/$PATTERN/I s/^#//'"
elif [[ "$ACTION_CHOICE" == "2" ]]; then
    ACTION="Comment"
    # Case-insensitive match: adds '#' to lines matching the pattern if not already commented
    SED_CMD="sed -E '/$PATTERN/I { /^[^#]/s/^/#/ }'"
else
    echo "Invalid action selection. Exiting."
    exit 1
fi

# Execute on all servers in the selected group
echo "Performing '$ACTION' on stop/start crontabs in group $GROUP_CHOICE..."
for SERVER in ${SERVER_GROUPS[$GROUP_CHOICE]}; do
    echo "Connecting to $SERVER..."

    ssh "$SERVER" "
        echo 'Backing up current crontab...';
        crontab -l > ~/crontab_backup_\$(date +%F_%T).bak 2>/dev/null;
        echo 'Applying change to crontab...';
        crontab -l | $SED_CMD | crontab -
    "

    if [ $? -eq 0 ]; then
        echo " $ACTION completed successfully for stop/start scripts on $SERVER."
    else
        echo " Failed to perform $ACTION on $SERVER."
    fi
    echo "-------------------------------------------"
done
