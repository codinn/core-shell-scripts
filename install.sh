#!/usr/bin/env sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/codinn/core-shell-scripts/master/install.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/codinn/core-shell-scripts/master/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/codinn/core-shell-scripts/master/install.sh
#   sh install.sh
#

set -e

cat >~/.shrc_Core_Shell <<EOM
# Bash/Zsh support for Core Shell.
#
# Report Working Directory
# Tell the Core Shell about the current working directory at each prompt.

if [ -n "\$BASH_VERSION" ]; then

    # Reference: /etc/bashrc_Apple_Terminal on macOS
    if [ -z "\$INSIDE_EMACS" ]; then
        update_coreshell_cwd() {
            # Identify the directory using a "file:" scheme URL, including
            # the host name to disambiguate local vs. remote paths.
            
            # Percent-encode the pathname.
            local url_path=''
            {
                # Use LC_CTYPE=C to process text byte-by-byte. Ensure that
                # LC_ALL isn't set, so it doesn't interfere.
                local i ch hexch LC_CTYPE=C LC_ALL=
                for ((i = 0; i < \${#PWD}; ++i)); do
                    ch="\${PWD:i:1}"
                    
                    if [[ "\$ch" =~ [/._~A-Za-z0-9-] ]]; then
                        url_path+="\$ch"
                    else
                        printf -v hexch "%02X" "'\$ch"
                        # printf treats values greater than 127 as
                        # negative and pads with "FF", so truncate.
                        url_path+="%\${hexch: -2:2}"
                    fi
                done
            }

            if [ -n "\$TMUX" ]; then
                printf '\ePtmux;\e\e]7;%s\a\e\\' "file://\$HOSTNAME\$url_path"
            else
                printf '\e]7;%s\a' "file://\$HOSTNAME\$url_path"
            fi
        }

        PROMPT_COMMAND="update_coreshell_cwd\${PROMPT_COMMAND:+; \$PROMPT_COMMAND}"
    fi

elif [ -n "\$ZSH_VERSION" ]; then

    # Reference: /etc/zshrc_Apple_Terminal on macOS
    if [ -z "\$INSIDE_EMACS" ]; then
        update_coreshell_cwd() {
            # Identify the directory using a "file:" scheme URL, including
            # the host name to disambiguate local vs. remote paths.

            # Percent-encode the pathname.
            local url_path=''
            {
                # Use LC_CTYPE=C to process text byte-by-byte. Ensure that
                # LC_ALL isn't set, so it doesn't interfere.
                local i ch hexch LC_CTYPE=C LC_ALL=
                for ((i = 1; i <= \${#PWD}; ++i)); do
                ch="\$PWD[i]"
                if [[ "\$ch" =~ [/._~A-Za-z0-9-] ]]; then
                    url_path+="\$ch"
                else
                    printf -v hexch "%02X" "'\$ch"
                    url_path+="%\$hexch"
                fi
                done
            }


            if [ -n "\$TMUX" ]; then
                printf '\ePtmux;\e\e]7;%s\a\e\\' "file://\$HOST\$url_path"
            else
                printf '\e]7;%s\a' "file://\$HOST\$url_path"
            fi
        }

        # Register the function so it is called at each prompt.
        autoload add-zsh-hook
        add-zsh-hook precmd update_coreshell_cwd
    fi
    
fi
EOM

grep -qs "\.shrc_Core_Shell" ~/.bash_profile || printf '\n[[ -n "$SSH_TTY" || -n "$SSH_CONNECTION" ]] && [ -r "$HOME/.shrc_Core_Shell" ] && . "$HOME/.shrc_Core_Shell" || true' >> ~/.bash_profile
grep -qs "\.shrc_Core_Shell" ~/.zshrc || printf '\n[[ -n "$SSH_TTY" || -n "$SSH_CONNECTION" ]] && [ -r "$HOME/.shrc_Core_Shell" ] && . "$HOME/.shrc_Core_Shell" || true' >> ~/.zshrc

rm -rf ~/.bashrc_Core_Shell
