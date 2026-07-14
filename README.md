# Oracle EBS Bulk Crontab Manager

An interactive Bash utility for Oracle Apps DBAs to bulk enable (uncomment) or disable (comment out) stop/start cron jobs across predefined Oracle EBS server groups via SSH.

# Features
* **Environment Grouping:** Cluster nodes easily (TEST, DEV, DBA, PRD).
* **Automated Backups:** Creates a '~/crontab_backup_[TIMESTAMP].bak' file on the target server before any changes.
* **Safe Regex Matching:** Uses case-insensitive 'sed' to match 'start' and 'stop' scripts without double-commenting.


#How to Use
1. Give execution permissions to the script:
   '''bash
   chmod +x Update_cron.sh
