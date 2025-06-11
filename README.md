Designed to automate the process of updating a specific set of configuration files on a Linux system. It performs backups of the original files before applying a series of predefined text replacements using the `sed` command.

This is particularly useful for reconfiguring an application environment, such as changing IP addresses, server types, or log levels, after a new deployment or migration.

## Features

* **Automatic Backups**: Creates a `.bak` copy of each configuration file before making any changes.
* **Centralized Configuration**: All file paths and IP addresses are defined as variables at the top of the script for easy modification.
* **Modular Updates**: Each configuration file is updated in its own dedicated section.
* **Error Checking**: The script checks if files exist before attempting to modify them and reports the status after each operation.
* **Clear Logging**: Prints a step-by-step log of its actions, including backups, applied changes, and any errors encountered.

***

## Configuration

Before running the script, you may need to adjust the variables in the **Configuration Section** at the top of the file to match your environment.

### File Paths

* `UH_CONFIG_FILE`: Path to `UpdateHandler.config`.
* `VAL_CONFIG_FILE`: Path to `Validator.config`.
* `DSM_CONFIG_FILE`: Path to `DeviceServiceMonitor.config`.
* `PTOPROF_FILE`: Path to `/etc/profile.d/pto-profile.sh`.

### IP Addresses and Values

* `IP_BASE`: The new primary IP address to be used.
* `IP_BASE_PTO`: The new base IP subnet (e.g., "172.23.26.").
* `OLD_IP_SFTP`, `OLD_IP_DSM`, `OLD_IP_GATEWAY`: The old values that need to be replaced.

***

## How to Use

1.  **Configure the Script**: Open the script file and edit the variables in the **Configuration Section** to match your requirements.
2.  **Make the Script Executable**: Before running, you must give the script execute permissions.
    ```bash
    chmod +x your_script_name.sh
    ```
3.  **Run the Script**: Execute the script, preferably with `sudo` if you are modifying files in protected directories like `/etc`.
    ```bash
    sudo ./your_script_name.sh
    ```
4.  **Review the Output**: Check the console output for any errors or warnings to ensure all files were updated successfully.

***

## Script Breakdown

### 1. Backup Process

The script first calls the `backup_config_files` function. It iterates through the files listed in the `CONFIG_FILES_TO_BACKUP` variable and copies each one to a new file with a `.bak` extension (e.g., `Validator.config` becomes `Validator.config.bak`).

### 2. Configuration Updates

The script then proceeds to update each of the following files with specific changes:

* **`Validator.config`**:
    * Changes `MinimumLogLevel` to `Debug`.
    * Switches server types from `SFTP` to `FTP`.
    * Updates various IP endpoints to the new `IP_BASE`.
* **`UpdateHandler.config`**:
    * Changes `MinimumLogLevel` to `Debug`.
    * Switches server type from `SFTP` to `FTP`.
    * Updates the endpoint and sets the `RemoteFolder`.
* **`DeviceServiceMonitor.config`**:
    * Updates the `<Server>` IP address.
* **`pto-profile.sh`**:
    * Updates the `DEVICE_BASE_IP` and the `GATEWAY` export variables.

### Important Notes

* **Idempotency**: The script uses `sed -i` to perform in-place edits. Running the script multiple times may have unintended consequences if the search patterns still match. The backups are crucial for recovery.
* **Root Permissions**: Since the script modifies files in both `/var/opt/` and `/etc/`, it will likely need to be run by a user with `sudo` privileges.
* **Restoring Backups**: If something goes wrong, you can manually restore a file from its backup by running:
    ```bash
    sudo cp /path/to/config.file.bak /path/to/config.file
    ```

***
