#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo -e "\033[0;31m This script must be run as root. Please use sudo."
    exit 1
fi

# Define default language
language="en_US" # Available Options: "en_US", "pt_BR"

# Set the language based on the system language
auto_detect_language=false # true or false. Default: true

# Path to Laradock. This is the path where Laradock is located.
laradock_path="/home/Laradock/laradock" # without trailing slash

# Docker Apache2 restart command
docker_apache2_restart_command="docker restart laradock_apache2_1"

# Path to Apache2
apache_path="$laradock_path/apache2/sites" # without trailing slash

# Path to the Projects directory. APP_CODE_PATH_HOST on .env file in Laradock
projects_path="/home/Projects" # without trailing slash

# Path to the /etc/hosts file
host_file="/etc/hosts" # default: "/etc/hosts"

# Category identifier. CAT_NAME_HERE will be replaced by the category name. Do not use spaces or special characters.
category_slug="##CATEGORY:CAT_NAME_HERE##"

# Default category list. These categories will be displayed in the selection list.
# You can add or remove categories as needed.
# Do not use spaces or special characters in the category names.
default_categories=(
    "Category1"
    "OpenSource"
    "MicroSaas"
    "Saas"
    "Personal"
)

# Virtual Host Template
# This template will be used to create the new VirtualHost configuration.
# You can customize the template as needed.
# Make sure to keep the placeholders DOMAIN_NAME, PROJECT_PATH, and PROJECT_FOLDER_NAME.
# The script will replace these placeholders with the actual values.
virtual_host_template="
<VirtualHost *:80>
    ServerName DOMAIN_NAME
    DocumentRoot \"/var/www/PROJECT_PATH/PROJECT_FOLDER_NAME/public\"

    <Directory \"/var/www/PROJECT_PATH/PROJECT_FOLDER_NAME/public\">
        Options +Indexes +Includes +FollowSymLinks +MultiViews
        <IfVersion < 2.4>
            Allow from all
        </IfVersion>
        <IfVersion >= 2.4>
            Require all granted
        </IfVersion>
    </Directory>
</VirtualHost>"

################################################################################
################################################################################
################################################################################
#
# DO NOT EDIT BELOW THIS LINE
# The script will not work if you edit below this line
#
################################################################################
################################################################################
################################################################################

###################
# Text translations
###################

# Portugues (pt_BR)
declare -A texts_pt_BR=(
    ["welcome"]="Bem-vindo ao script de criação de VirtualHosts para Linux!"
    ["developed_by"]="Desenvolvido por:"
    ["version"]="Versão:"
    ["project_name_prompt"]="Digite o nome do projeto (case sensitive): "
    ["select_directory"]="Selecione o diretório onde deseja criar o projeto:"
    ["select_apache_config"]="Selecione o arquivo de configuração do Apache2:"
    ["invalid_option"]="Opção inválida. Por favor, digite 's' ou 'n'."
    ["creating_directory"]="Criando o diretório do projeto em"
    ["error_creating_directory"]="Erro ao criar o diretório do projeto. Verifique as permissões."
    ["adding_virtualhost"]="Adicionando o novo VirtualHost ao arquivo de configuração do Apache2..."
    ["select_valid_directory"]="Selecione um diretório válido."
    ["select_valid_config"]="Selecione um arquivo de configuração válido."
    ["searching_categories"]="Buscando categorias existentes no arquivo de hosts..."
    ["invalid_category_name"]="Nome inválido. Por favor, digite um nome sem espaços ou caracteres especiais."
    ["category_already_exists"]="A categoria já existe. Por favor, escolha outro nome."
    ["new_category_created"]="Nova categoria criada:"
    ["summary_info"]="Resumo das informações coletadas:"
    ["summary_project_name"]="Nome do Projeto:"
    ["summary_project_directory"]="Diretório do Projeto:"
    ["summary_project_path"]="Caminho do Projeto:"
    ["summary_category"]="Categoria:"
    ["summary_apache_config"]="Arquivo de configuração do Apache2:"
    ["summary_virtualhost"]="Novo VirtualHost:"
    ["summary_domain"]="Novo domínio:"
    ["invalid_option_continue"]="Opção inválida. Por favor, digite 'y' ou 'n'."
    ["confirm_process"]="Deseja continuar? "
    ["creating_project_directory"]="Criando o diretório do projeto em"
    ["creating_public_directory"]="Criando o diretório public em"
    ["error_creating_public_directory"]="Erro ao criar o diretório public. Verifique as permissões."
    ["adding_domain_to_hosts"]="Adicionando o novo domínio ao arquivo /etc/hosts..."
    ["category_found"]="Categoria encontrada no arquivo de hosts. Adicionando o domínio..."
    ["domain_added_to_hosts"]="Domínio adicionado ao arquivo de hosts com sucesso."
    ["restarting_apache"]="Reiniciando o Apache2 no Laradock..."
    ["script_success"]="Script executado com sucesso!"
    ["script_cancelled"]="Script cancelado pelo usuário."
    ["domain_exists"]="O domínio já existe no arquivo de hosts. Nenhuma ação necessária."
    ["category_not_found"]="Categoria não encontrada. Criando nova categoria e adicionando o domínio..."
    ["domain_added"]="Domínio adicionado ao arquivo de hosts com sucesso."
    ["success_message"]="VirtualHost criado com sucesso para o projeto"
    ["access_project"]="Acesse o projeto em"
)
# English (en_US)
declare -A texts_en_US=(
    ["welcome"]="Welcome to the VirtualHosts creation script for Linux!"
    ["developed_by"]="Developed by:"
    ["version"]="Version:"
    ["project_name_prompt"]="Enter the project name (case sensitive): "
    ["select_directory"]="Select the directory where you want to create the project:"
    ["select_apache_config"]="Select the Apache2 configuration file:"
    ["invalid_option"]="Invalid option. Please type 'y' or 'n'."
    ["creating_directory"]="Creating the project directory in"
    ["error_creating_directory"]="Error creating the project directory. Check permissions."
    ["adding_virtualhost"]="Adding the new VirtualHost to the Apache2 configuration file..."
    ["select_valid_directory"]="Select a valid directory."
    ["select_valid_config"]="Select a valid configuration file."
    ["searching_categories"]="Searching for existing categories in the hosts file..."
    ["invalid_category_name"]="Invalid name. Please enter a name without spaces or special characters."
    ["category_already_exists"]="The category already exists. Please choose another name."
    ["new_category_created"]="New category created:"
    ["summary_info"]="Summary of collected information:"
    ["summary_project_name"]="Project Name:"
    ["summary_project_directory"]="Project Directory:"
    ["summary_project_path"]="Project Path:"
    ["summary_category"]="Category:"
    ["summary_apache_config"]="Apache2 configuration file:"
    ["summary_virtualhost"]="New VirtualHost:"
    ["summary_domain"]="New domain:"
    ["invalid_option_continue"]="Invalid option. Please type 'y' or 'n'."
    ["confirm_process"]="Do you want to continue? "
    ["creating_project_directory"]="Creating the project directory in"
    ["creating_public_directory"]="Creating the public directory in"
    ["error_creating_public_directory"]="Error creating the public directory. Check permissions."
    ["adding_domain_to_hosts"]="Adding the new domain to the /etc/hosts file..."
    ["category_found"]="Category found in the hosts file. Adding the domain..."
    ["domain_added_to_hosts"]="Domain successfully added to the hosts file."
    ["restarting_apache"]="Restarting Apache2 in Laradock..."
    ["script_success"]="Script executed successfully!"
    ["script_cancelled"]="Script cancelled by the user."
    ["domain_exists"]="The domain already exists in the hosts file. No action needed."
    ["category_not_found"]="Category not found. Creating a new category and adding the domain..."
    ["domain_added"]="Domain successfully added to the hosts file."
    ["success_message"]="VirtualHost successfully created for the project"
    ["access_project"]="Access the project at"
)

# Detect system language, and remove the encoding part
if [[ "$LANG" == *".UTF-8" ]]; then
    LANG="${LANG%.UTF-8}"
fi

# Get all available languages from translations.sh
available_languages=()
for lang in "${!texts_@}"; do
    # Remove the prefix "texts_" from the variable name
    lang="${lang#texts_}"
    # Add the language to the array
    available_languages+=("$lang")
done

# Check if auto-detect is enabled
if [[ "$auto_detect_language" == true ]]; then
    # Check if the system language is available in translations.sh
    if [[ " ${available_languages[@]} " =~ " $LANG " ]]; then
        # If the system language is available, set it
        language="$LANG"
    else
        # If the system language is not available, set default to en_US
        language="en_US"
    fi
else
    # Check if the defined language is available
    if [[ " ${available_languages[@]} " =~ " $language " ]]; then
        # If the language is available, set it
        language="$language"
    else
        # If the language is not available, set default to en_US
        language="en_US"
    fi
fi

developer_name="Smarty Scripts"
developer_website="https://smartyscripts.com"
script_vesion="1.0.0"

# Text colors
green='\033[0;32m'
blue='\033[0;34m'
red='\033[0;31m'
yellow='\033[0;33m'
white='\033[0;37m'

# Translation function by key
display_message() {
    local key="$1"
    local message="NOT_FOUND_STRING_MESSAGE"
    local texts_var="texts_$language"

    if declare -p "$texts_var" &>/dev/null; then
        declare -n texts="$texts_var"
        if [[ -n "${texts[$key]}" ]]; then
            message="${texts[$key]}"
        fi
    fi

    echo -e "$message"
}

# Read the projects folder and assign all found folders to the variable projects. Do not list the root directory (/).
all_projects=$(find "$projects_path" -maxdepth 1 -type d)

# Remove the projects directory path, keeping only the folder names
projects=$(echo "$all_projects" | sed 's|'"$projects_path/"'||g' | sort)

# Find the item "/mnt/1282CEC77B887CA3/Projetos" in projects and rename it to "CURRENT_ROOT"
projects=$(echo "$projects" | sed 's|'"$projects_path"'|/|g')

# Get all Apache2 configuration files and assign them to the variable virtual_hosts
all_virtual_hosts=$(ls "$apache_path"/*.conf)

# Remove the Apache2 configuration directory path, keeping only the file names
virtual_hosts=$(echo "$all_virtual_hosts" | sed 's|'"$apache_path/"'||g')

# Display a welcome message, informing the script name, creator, website, version, date, and the name Laradock written in ASCII characters
echo -e "${green}$(display_message "welcome")${white}"
echo -e "${green}$(display_message "developed_by") $developer_name ($developer_website)${white}"
echo -e "${green}$(display_message "version") $script_vesion${white}"

# Prompt for the Project name
read -p "$(display_message "project_name_prompt")" project_name

# Create a variable: project_folder_name replacing spaces with -
project_folder_name=$(echo "$project_name" | tr ' ' '-')

# Convert the project name to lowercase and create the domain
domain=$(echo "$project_folder_name" | tr '[:upper:]' '[:lower:]').local

# Ask in which directory the project should be created, using a selection list.
echo "$(display_message "select_directory")"
select project_path in $projects; do
    if [[ -n "$project_path" ]]; then
        break
    else
        echo "$(display_message "select_valid_directory")"
    fi
done

# Ask the user which Apache2 configuration file they want to use
echo "$(display_message "select_apache_config")"
select virtual_host in $virtual_hosts; do
    if [[ -n "$virtual_host" ]]; then
        break
    else
        echo "$(display_message "select_valid_config")"
    fi
done

# Create the new virtual host configuration, based on the template
# Replace the placeholders in the template with the actual values
new_virtual_host=$(echo "$virtual_host_template" | sed -e "s|DOMAIN_NAME|$domain|g" \
    -e "s|PROJECT_PATH|$project_path|g" \
    -e "s|PROJECT_FOLDER_NAME|$project_folder_name|g")


# Replace the fixed identifier CAT_NAME_HERE with the search pattern
category_pattern="${category_slug/CAT_NAME_HERE/(.*)}"

# Search for existing categories in the hosts file
echo -e "${green}$(display_message "searching_categories")${white}"
existing_categories=()
while IFS= read -r line; do
    if [[ "$line" =~ $category_pattern ]]; then
        category_name="${BASH_REMATCH[1]}"
        existing_categories+=("$category_name")
    fi
done < "$host_file"

# Remove duplicates and add the found categories to the default category array
existing_categories=($(echo "${existing_categories[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
default_categories+=("${existing_categories[@]}")

# Remove duplicates from the final array
default_categories=($(echo "${default_categories[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# Function to validate the category name
validate_category_name() {
    local name="$1"
    if [[ -z "$name" || "$name" =~ [^a-zA-Z0-9] ]]; then
        echo -e "${red}$(display_message "invalid_category_name")${white}"
        return 1
    fi
    # Check if the category name already exists
    if category_exists "$name"; then
        echo -e "${red}$(display_message "category_already_exists")${white}"
        return 1
    fi
    return 0
}

# Function to check if the category name already exists
category_exists() {
    local name="$1"
    for existing_category in "${default_categories[@]}"; do
        if [[ "$existing_category" == "$name" ]]; then
            return 0
        fi
    done
    return 1
}

# Ask the user which category the project belongs to
echo "$(display_message "select_directory")"
select category in "${default_categories[@]}" "$(display_message "new_category_created")"; do
    if [[ "$category" == "$(display_message "new_category_created")" ]]; then
        # Prompt for the new category name, it cannot be empty and cannot contain spaces or special characters
        read -p "$(display_message "invalid_category_name")" new_category
        # Check if the new category name is valid
        while ! validate_category_name "$new_category"; do
            read -p "$(display_message "category_already_exists")" new_category
        done        
        # Add the new category to the array
        default_categories+=("$new_category")
        category="$new_category"
        echo -e "${green}$(display_message "new_category_created"): $category${white}"
        break
    elif [[ -n "$category" ]]; then
        break
    else
        echo "$(display_message "select_valid_directory")"
    fi
done

# Display a summary of the collected information and ask if the user wants to continue
echo -e "${green}$(display_message "summary_info")${white}"
echo -e "$(display_message "summary_project_name"): ${blue}$project_name${white}"
echo -e "$(display_message "summary_project_directory"): ${blue}$project_path/$project_folder_name${white}"
echo -e "$(display_message "summary_project_path"): ${blue}$projects_path/$project_path/$project_folder_name${white}"
echo -e "$(display_message "summary_category"): ${blue}$category${white}"
echo -e "$(display_message "summary_apache_config"): ${blue}$virtual_host${white}"
echo -e "$(display_message "summary_virtualhost"): ${blue}$new_virtual_host${white}"
echo -e "$(display_message "summary_domain"): ${blue}$domain${white}"

# Ask if the user wants to continue, with options "y" or "n", defaulting to "y"
read -p "$(display_message "confirm_process") (y/n) [y]: " confirm

# If the user does not type anything, the default will be "y"
if [[ -z "$confirm" ]]; then
    confirm="y"
fi

# If the user types an option other than "y" or "n", display an error message and exit the script
if [[ "$confirm" != "y" && "$confirm" != "Y" && "$confirm" != "n" && "$confirm" != "N" ]]; then
    echo -e "${red}$(display_message "invalid_option_continue")${white}"
    exit 1
fi

# If the user types "n" or "N", the script will be terminated
if [[ "$confirm" == "n" || "$confirm" == "N" ]]; then
    echo -e "${red}$(display_message "script_cancelled")${white}"
    exit 1
fi

# Create the project directory in the chosen folder
echo -e "${green}$(display_message "creating_project_directory") $projects_path/$project_path/$project_folder_name...${white}"
mkdir -p "$projects_path/$project_path/$project_folder_name"

# Check if the directory was successfully created
if [[ $? -ne 0 ]]; then
    echo -e "${red}$(display_message "error_creating_directory")${white}"
    exit 1
fi

# Create the public directory inside the project
echo -e "${green}$(display_message "creating_public_directory") $projects_path/$project_path/$project_folder_name...${white}"
mkdir -p "$projects_path/$project_path/$project_folder_name/public"

# Check if the public directory was successfully created
if [[ $? -ne 0 ]]; then
    echo -e "${red}$(display_message "error_creating_public_directory")${white}"
    exit 1
fi

# Open the virtual_hosts file chosen by the user
echo -e "${green}$(display_message "adding_virtualhost")${white}"

# Add the new VirtualHost to the Apache2 configuration file
echo -e "$new_virtual_host" >> "$apache_path/$virtual_host"

# Add the new domain to the /etc/hosts file
echo -e "${green}$(display_message "adding_domain_to_hosts")${white}"

# Replace the fixed identifier CAT_NAME_HERE with the search pattern
category_pattern="${category_slug/CAT_NAME_HERE/(.*)}"

# Check if the domain already exists in the /etc/hosts file
if grep -q "$domain" "$host_file"; then
    echo -e "${yellow}$(display_message "domain_exists")${white}"
else
    # Search for the category in the hosts file
    if grep -qE "$category_pattern" "$host_file"; then
        echo -e "${green}$(display_message "category_found")${white}"
        # Add the domain right below the corresponding category, using the category_pattern
        category_entry="${category_slug/CAT_NAME_HERE/$category}"
        echo -e "\n$category_entry\n127.0.0.1 $domain" >> "$host_file"
    else
        # If the category does not exist, create a new category and add the domain
        echo -e "${yellow}$(display_message "category_not_found")${white}"
        new_category_entry="${category_slug/CAT_NAME_HERE/$category}"
        echo -e "\n$new_category_entry\n127.0.0.1 $domain" >> "$host_file"
    fi
    # Add a line break after the domain
    sed -i "/127.0.0.1 $domain/a\\" "$host_file"
    echo -e "${green}$(display_message "domain_added")${white}"
fi

# Restart Apache2 in Laradock
echo -e "${green}$(display_message "restarting_apache")${white}"
$docker_apache2_restart_command

# Display a success message
echo -e "${green}$(display_message "success_message") $project_name in $project_path/$project_folder_name.${white}"
echo -e "${green}$(display_message "access_project") http://$domain${white}"
echo -e "${green}$(display_message "script_success")${white}"
exit 1