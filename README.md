# Laradock Create Project Script

This project provides a Bash script to automate the setup of local development environments using Laradock and Apache2. It simplifies the creation of project directories, VirtualHost configurations, and domain setup in the hosts file, ensuring a streamlined and efficient workflow for developers.

## Features

- Automatically detects or sets the system language.
- Creates project directories with a predefined structure.
- Configures Apache2 VirtualHosts dynamically.
- Updates the hosts file with the new domain, organized by categories.
- Restarts Apache2 in the Laradock environment to apply changes.
- Provides user-friendly prompts and feedback messages.

## Requirements

- **Operating System**: Linux or macOS with Bash support.
- **Dependencies**:
  - Docker and Laradock installed and configured.
  - Apache2 available in the Laradock environment.
  - `sed` and `find` utilities installed.
- **Permissions**: Must be run as root or with `sudo` to modify system files like `/etc/hosts`.

## Compatibility

- **Languages**: Supports English (`en_US`) and Portuguese (`pt_BR`).
- **Environment**: Designed for use with Laradock and Apache2.

## Configurable Variables

The script includes several variables that can be customized to fit your environment:

- **`language`**: Default language for messages. Options: `"en_US"`, `"pt_BR"`.
- **`auto_detect_language`**: Automatically detect the system language. Options: `true`, `false`.
- **`laradock_path`**: Path to the Laradock directory. Example: `"/home/user/Laradock"`.
- **`docker_apache2_restart_command`**: Command to restart Apache2 in Laradock. Default: `"docker restart laradock_apache2_1"`.
- **`apache_path`**: Path to the Apache2 configuration directory. Example: `"$laradock_path/apache2/sites"`.
- **`projects_path`**: Path to the directory where projects will be created. Example: `"/home/user/Projects"`.
- **`host_file`**: Path to the hosts file. Default: `"/etc/hosts"`.
- **`category_slug`**: Identifier for categories in the hosts file. Default: `"##CATEGORY:CAT_NAME_HERE##"`.
- **`default_categories`**: List of default categories for organizing projects. Example: `("Tests" "OpenSource" "Saas")`.
- **`virtual_host_template`**: Template for creating Apache2 VirtualHost configurations.

## How to Use

1. Clone this repository to your local machine.
2. Open the script and adjust the configurable variables to match your environment.
3. Run the script with `sudo` or as root:
   ```bash
   sudo ./laradock_project_creator.sh
   ```
4. Follow the prompts to create a new project.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
