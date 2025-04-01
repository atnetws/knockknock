# knockknock.sh - SSH Access Management Script

## Description

`knockknock.sh` is a Bash script for managing SSH access using `ufw` (Uncomplicated Firewall). 
It allows temporary access to a specific port (default: 22 for SSH) based on the presence of a "knock file".

The script is particularly useful for users without static IP addresses who still need secure SSH access. It can be run periodically via `cron` to authorize or revoke access dynamically.

This script was originally designed to permanently block SSH access on publicly accessible servers using `ufw` while still allowing users without a static IP address to request temporary access. This is achieved through a web-based mechanism, such as a password-protected HTML form, that generates a knock file containing the user's IP address. The script then reads this file and dynamically grants access.

## How It Works

1. Checks if the knock file exists.
2. If the file exists, it reads the IP address from the file and grants access via `ufw`.
3. If the file does not exist, it reviews existing allowed IPs and removes unauthorized entries.
4. The knock file can be created manually or by any other script or process.

## Requirements

- `bash`
- `ufw` (Uncomplicated Firewall)

## Installation

1. Copy the script to a secure location, e.g., `/usr/local/bin/knockknock.sh`.
2. Ensure the script is executable:
   ```bash
   chmod +x /usr/local/bin/knockknock.sh
   ```
3. Adjust the knock file path and port settings as needed.

## Usage

The script can be executed manually or automatically via `cron`:

### Manual Execution
```bash
/usr/local/bin/knockknock.sh
```

### Automatic Execution via Crontab
A typical `cron` configuration could be:

```cron
* * * * * /usr/local/bin/knockknock.sh >> /var/log/knockknock.log 2>&1
```

This runs the script every minute and logs the output.

## Adjusting Parameters

If the default port or other parameters need to be adjusted, they can be modified directly in the script. Alternatively, a configuration file can be used if supported by the script.

## Creating the Knock File

The knock file can be generated in various ways, such as:

1. Using a web form (see provided cfm example).
2. Manually:
   ```bash
   echo "192.168.1.100" > /path/to/knockfile
   ```
3. Automatically by another script:
   ```bash
   echo "$(curl -s ifconfig.me)" > /path/to/knockfile
   ```
4. Via a web request:
   ```bash
   wget -q -O - "https://example.com/authorize_ip" > /path/to/knockfile
   ```

## Security Considerations

- Ensure only authorized users can create or modify the knock file.
- Use a secure connection (e.g., SSH or VPN) to generate the knock file.
- Log all changes to track unauthorized access attempts.

## License

This script is released under the GPLv3 license.

## Credits

I appreciate any feedback or suggestions for improvements! If you have ideas on how to enhance the script, feel free to share them.

