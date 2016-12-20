function fish_prompt --description 'Write out the prompt'
    # Just calculate these once, to save a few cycles when displaying the prompt
        if not set -q __fish_prompt_hostname
                set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
        end
         if not set -q __fish_prompt_normal
                set -g __fish_prompt_normal (set_color normal)
        end
         if not set -q __git_cb
                set __git_cb "["(set_color brown)(git branch ^/dev/null | grep \* | sed 's/* //')(set_color normal)"]"
        end
        if set -q VIRTUAL_ENV
            set VE_NAME "("(echo $VIRTUAL_ENV | awk -F/ '{print $NF}')")"
        else
            set VE_NAME ""
        end
         switch $USER
                 case root
                     if not set -q __fish_prompt_cwd
                            if set -q fish_color_cwd_root
                                    set -g __fish_prompt_cwd (set_color $fish_color_cwd_root)
                            else
                                    set -g __fish_prompt_cwd (set_color $fish_color_cwd)
                            end
                     end
                     printf '%s@%s:%s%s%s%s# ' $USER $__fish_prompt_hostname "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal" $__git_cb
                 case '*'
                     if not set -q __fish_prompt_cwd
                            set -g __fish_prompt_cwd (set_color $fish_color_cwd)
                    end

                    printf '%s%s@%s [%s%s%s] %s\n-> ' $VE_NAME $USER $__fish_prompt_hostname "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal" $__git_cb
         end
end



set -g VIRTUAL_ENV_DISABLE_PROMPT 1
function workon --description "activate virtualenv"
     source ~/.venvs/$argv[1]/bin/activate.fish
end

function ack --description "ack"
     ack-grep $argv  --ignore-dir=migrations --ignore-dir=buid
end

function descrotify --description "rename screenshots"
    for name in (ls *scrot*)
        set new_name (echo $name | sed s/_scrot// )
        mv $name $new_name
    end
end


set -x PIP_DOWNLOAD_CACHE '/home/rciorba/.pip_cache'
set -x PATH $PATH /home/rciorba/repos/misc/bin
set -x LANG en_US.UTF-8
set -x KERL_ENABLE_PROMPT 1

