# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

export HISTFILESIZE=-1
export HISTSIZE=-1
export HISTCONTROL=ignoreboth:erasedups

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=


#######
# Git #
#######

alias cdgr='cd $(git rev-parse --show-toplevel) '
alias git-branches='( git remote show origin && git branch -a ) | sort -u'
alias git-log="git log --name-only --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit "
alias git-short-log='git log --date=short --pretty=format:"%C(yellow)%h%Cblue%>(12)%ad %Cgreen%<(7)%aN%Cred%d %Creset%s" '
alias git-status="git status | sed -e '/^Untracked/,\${/\.\./d}' "
alias git-add-modif='git add $(git status | sed -ne "/\s\+modified:/{s/modified://;p}" )'
alias git-reset-last='git reset --soft HEAD~1 '
alias git-reset-last-hard='git reset --hard HEAD~1 '
alias git-fetch='git fetch --all --tags --force'
alias git-my-log="git log --pretty=format:'%h - %an, %ar : %s' | grep -E 'Bruchanov|BruXy' | grep -v Merge"
alias git-add-modified='git status | grep modified | cut -d: -f2 | xargs git add '
alias git-compare-master="git diff --name-status master"
alias this-branch="git rev-parse --abbrev-ref HEAD"
alias git-rebase-master='git-fetch && git pull --rebase --autostash origin master || git pull --rebase --autostash origin main'
alias gh-search='gh search issues --repo advthreat/tenzin '
alias git-diff='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset" --abbrev-commit --date=relative'
alias git-pull-origin='git pull origin $(this-branch)'
alias git-blame='git blame -c --date=format:%Y-%m-%d '
alias git-history='git log -p -- '
alias git-diff='git diff --cached --color-words '
alias git-pull-master='git pull origin master '
alias git-stash-diff='git stash show -p stash@{0} '
alias git-link='~/.git/hooks/pre-push'
alias git-pr-check='gh pr view --json url -q .url '
alias gcm='git checkout master || git checkout main && git pull '
alias gp='git-fetch && git pull'
alias git-repo='( cdgr; grep url .git/config  | sed -e "s/^.*@/https:\/\//" -e "sXcom:Xcom/X" -e "s/.git$//" ) '
alias vimdiff="vimdiff -c 'set diffopt+=iwhiteall' "


function git-checkout() {
    [[ "$1" == "-b" ]] && shift

    url=$1
    [[ -z "$url" ]] && { echo "Usage: git-checkout <git-url> [branch-info]" 1>&2; return 1; }
    branch=$(basename "$url")
    info=${2:-"Missing branch info!"}
    current=$(git rev-parse --abbrev-ref HEAD)

    if [[ "$current" != master && "$current" != main ]] ; then
        printf "This is not branched from master or main!\n" 1>&2
        return 1
    fi

    git checkout -b ${branch}_${info}
    printf "%s %s %s\n" "$url" "${branch}_${info}" "$(basename $(pwd))" >> ~/.jira_branches
}

function git-show-names() {
    local commit=$1

    git log --name-only $commit |\
        sed -n '/^commit/{p; :loop n; p; /^commit/q; b loop}' | sed '$d'
}

function git-pr() {
    msg="$(git log -1 --pretty=%B)"
    branch="$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD)"
    url=$(grep -F "$branch" ~/.jira_branches | cut -d' ' -f1)
    gh pr create --base main --head $branch --title "$msg" --body "### References:$url"
}

GIT_COMPLETITION=~/.git-completion.bash
if [ ! -f $GIT_COMPLETITION ] ; then
    curl -s https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
         -o $GIT_COMPLETITION
fi

source ~/.git-completion.bash

##############
# Terraform  #
##############

alias tf_list='terraform state list | sort -u | sed -e "s/^\(.*\)/\1/" | column -t -s" "'
alias tf_log='printf "Current TF_LOG=\"%s\"\n" $TF_LOG

    debug_level=(
        TRACE
        DEBUG
        INFO
        WARN
        ERROR
        JSON
        unset
    )
    COLUMNS=20
    select level in ${debug_level[*]}
    do
        if [[ "$level" == "unset" ]] ; then
            unset TF_LOG
            printf "TF_LOG is unset.\n"
        else
            export TF_LOG=$level
        fi
        break
    done'


# Remove all color codes from output
alias uncolor='sed -e "s/\x1b\[[0-9;]*m//g"'

alias tf_fmt_check='terraform fmt -check -diff -recursive'
alias tf_fmt='terraform fmt -recursive'
alias tf_clear='rm -rf ./.terraform .terraform.lock.hcl'

tf_state() {
    local data="./tfplan-$$"
    terraform plan -out=$data
    terraform show -json $data | jqless
}

tf_unlock() {
    LOCK=$(terraform plan |& sed -ne '/ ID:/{s/.*ID: *//;p}')
    if [ -n "$LOCK" ] ; then
        printf "Unlocking Terraform state: %s\n" "$LOCK"
        terraform force-unlock -force $LOCK
    else
        printf "No lock found.\n"
    fi
}


#######
# AWS #
#######

alias aws_identity='aws sts get-caller-identity'
alias aws_asg='aws autoscaling describe-auto-scaling-groups --query="AutoScalingGroups[].[AutoScalingGroupName,DesiredCapacity]" --out text'
alias aws_sg='aws ec2 describe-security-groups --group-ids '
alias aws_hw='aws ec2 describe-instance-types --instance-types '
alias list-buckets='aws s3api list-buckets --query "Buckets[].Name" | jq -r sort[]'
alias list-lambdas='aws lambda list-functions --query="Functions[].FunctionName" | jq -r sort[]'
alias log-groups='aws logs describe-log-groups --query "logGroups[].logGroupName"'
alias dynamodb-tables='aws dynamodb list-tables --query "TableNames[]" --output text'

aws_instances ()
{
    local aws_region;
    for aws_region in us-east-1 us-east-2;
    do
        echo ---------;
        echo ${aws_region};
        echo ---------;
        aws ec2 --region "${aws_region}" describe-instances | jq -cr '.Reservations[].Instances[] |
        ( [ ((.Tags[]? // {} | select(.Key == "Name") | .Value) // "(none)",
             ": ",
             (.PublicDnsName | if . == "" then "(none)" else . end) // "(none)",
             ", ",
             (.PrivateIpAddress | if . == "" then "(none)" else . end) // "(none)"),
            " (",
            .InstanceType, ", ",
            .State.Name, ")"
          ] | add )' | sort;
    done
}

function get_token() {
    local secret="$1"
    aws ssm get-parameters \
        --names=$secret \
        --with-decryption --query='Parameters[].Value' \
        --out text
}

REGIONS=(
    us-east-1 
    us-east-2 
    eu-west-1 
    eu-central-1 
    ap-northeast-1 
    ap-southeast-2
)

alias region='printf "Current AWS region: %s\n" "$AWS_DEFAULT_REGION"
    select region in ${REGIONS[*]}
    do
        export AWS_DEFAULT_REGION=$region
        break
    done'

########
# Tmux #
########

alias tmux5w='tmux new-session \; neww \; neww \; neww \; neww \; select-window -t 1'
alias tmux_display='export DISPLAY="`tmux show-env | sed -n s/^DISPLAY=//p`"'
alias tmux_history='tmux capture-pane -pS -'

function tmux_update() {
    for i in DISPLAY SSH_ASKPASS SSH_AUTH_SOCK SSH_AGENT_PID \
             SSH_CONNECTION WINDOWID XAUTHORITY
    do
        tmux set-option -g update-environment $i
    done
}

########
# Bash #
########

# Completions
source /etc/profile.d/bash_completion.sh

alias ll='eza --all --long --git --header --icons'
alias lt='eza --all --tree --icons'
alias tree='eza --all -T --icons'

# remove alias ls if it exists
alias ls >& /dev/null && unalias ls

function ls() {
    if [[ $* == *-Z* ]] ; then
        /usr/bin/ls $*
    fi

    if [ -t 1 ] ; then
        # Output to TTY
        eza -a --icons $*
    else
        /usr/bin/ls -a $*
    fi
}

alias grep_ipv4="grep -oE '((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'"
alias grep_ipv6="grep -oE '(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))
'"
alias chromekill='killall -s QUIT chrome '
alias chrome='/opt/google/chrome/chrome > /dev/null 2>&1 &'
alias ruby-syntax='for i in $(find . -name "*.rb"); do echo -ne "$i:\t" ;ruby -c $i; done'
alias wget_page='wget --no-parent -e robots=off -r -L'
alias set_display='export OLD_DISPLAY=$DISPLAY; export DISPLAY=$(__set_display) '
alias torrent_trackers='curl -s https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt | xclip -se c'
alias w='w -f' # show IP address
alias exdos_list='curl -s https://exodos.the-eye.eu/public/eXoDOS/Games/ | links -dump | grep -E "MiB|KiB"'
alias sqlformat='sqlformat - --reindent --keywords upper --use_space_around_operators'
alias yamllint='yamllint -c ~/yamllint.conf '
alias df='df -h '
alias scan-ssh='for i in {2..254}; do ssh-keyscan -T 1 192.168.255.$i; done'
alias www_perm='chcon -R -t httpd_sys_content_t * '
# Sum file size of content of working directory
alias wd_du='du -sh '
alias python3-syntax='python3 -m py_compile '
alias python-syntax='python -m py_compile '
alias flake8='flake8 --show-source '
alias autopep8='autopep8 --ignore=E265 ' #ignore comment formating
alias python3-pep8='python3 -m flake8 '
alias nicejson='python -m json.tool '
alias pip-update='pip freeze --local | grep -v "^\-e" | cut -d = -f 1  | xargs -n1 pip install -U '
alias pip3-update="pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U "
alias uncomment='grep -Ev "^#|^;|^$" '
alias findfile='find . -type f | grep -E -i '
alias finddir='find . -type d \( -name .git -o -name .terraform \) -prune -o -type d -print | grep -E -i '
alias ansi_cat='iconv -f cp437 -t utf-8 '
alias iconv_cp866='iconv -f cp866 -t utf-8 '
alias iso2utf='iconv -f iso-8859-1 -t utf-8 '
alias myip='curl -s ipinfo.io | jq .'
alias geeqie='geeqie --disable-clutter '
alias dosmount='VBoxManage internalcommands createrawvmdk -filename "dos.vmdk" -rawdisk /dev/sdb '
#export SDL_VIDEO_FULLSCREEN_HEAD=0

function bzip_stout() {
    bzip2 -c $* | base64
}

man() { MANWIDTH=$(( ${COLUMNS:-100} > 100 ? 100 : COLUMNS )) command man "$@"; }

function cdt ()
{
    INPUT="$1";
    if [ -d "$INPUT" ]; then
        cd "$INPUT";
    elif [ -e "$INPUT" ]; then
        cd "$(dirname $INPUT)";
    else
        cd $INPUT;
    fi
}

function unzip_all() {
    for i in *.zip ; do unzip -o $i; done
}

# Remove spaces
function rs() {
    for i in "$@"
    do
        [[ "$i" != "${i// /_}" ]] && mv -v "$i" "${i// /_}"
    done
}

function grepfiles() {
    opt=""
    params=""

    HELP=0
    [[ $* == *-h* ]] && HELP=1

    while [[ $# -gt 0 ]]; do
        arg="$1"
        if [[ "$arg" == -* ]]; then
            opt+="$arg "
        else
            params+="$arg "
        fi
        shift
    done

    if [[ $(git rev-parse --is-inside-work-tree) == "true" ]] ; then
        [ $HELP -eq 1 ] && { git grep -h ; return; }
        git grep $opt "$params"
    else
        [ $HELP -eq 1 ] && { grep -h ; return; }
        find . -path "*/.terraform" -prune -false -o -type f -print0 |\
            xargs --null grep -n $opt "$params"
    fi
}

function openssl_info(){
    local INPUT=$1
    if [ -f $INPUT ] ; then
    # Is it file?
        openssl x509  -noout -text -in $INPUT
    else
    # Check for host
        echo | openssl s_client -showcerts -connect $INPUT:443
    fi
}

function jqless() {
    local cmd='jq -C . | less -R'
    if [ -n "$*" ] ; then
        cat $* | eval $cmd
    else
        eval $cmd
    fi
}

## Prompt ##

parse_git_branch() {
    local branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [[ -n "$branch" ]]; then
        printf "(\e[35m%s\e[0;37m)\342\224\200" $branch
    else
        printf ""
    fi
}

#  \342\224\234 ├
#  \342\224\200 ─

# AWS_DEFAULT_REGION, AWS_PROFILE

get_aws_info() {
    if [[ -n "$AWS_PROFILE" ]] ; then
        printf "\n\342\224\234\342\224\200"
        printf "AWS:[%s]" "$AWS_PROFILE"
    else
        printf ""
        return
    fi

    if [[ -n "$AWS_DEFAULT_REGION" ]] ; then
        printf "\342\224\200[%s]" "$AWS_DEFAULT_REGION"
    fi
}

hist_cmd() {
    printf "($[\! + 1])"
}

export PS1="\[\033[0;37m\]\342\224\214\342\224\200\$([[ \$? != 0 ]] && echo \"[\[\033[0;31m\]\342\234\227\[\033[0;37m\]]\342\224\200\")[$(if [[ ${EUID} == 0 ]]; then echo '\[\033[0;31m\]\h'; else echo '\[\033[0;33m\]\u\[\033[0;37m\]@\[\033[0;96m\]\h'; fi)\[\033[0;37m\]]\342\224\200\$(parse_git_branch)[\[\033[0;32m\]\w\[\033[0;37m\]]\$(get_aws_info)\n\[\033[0;37m\]\342\224\224\342\224\200[\!]\342\224\200\342\224\200\342\225\274 \[\033[0m\]"

function context-update()
{
    old=$(context --version | grep current | cut -d'|' -f 2 | head -n1)
    (cd /usr/local/context/; bash install.sh --modules=all)
    printf "Old version was:\n %s\n" "$old"
    printf "New version is:\n"
    context --version | grep current | head -n1
}

function __set_display() {
    if [ -n "$SSH_TTY" ] ; then
        [ -t 0 ] && printf "SSH console detected." >&2
    fi
    port=$( ( [[ "$(w|sed -n '2s/.*FROM.*/1/p')" == '1' ]] && w || w -f) |\
            grep -Eo ' :[0-9]+').0
    if [ -z "$port" ] ; then
        [ -t 0 ] && printf "Cannot determine DISPLAY port" >&2
        return 1
    else
        [ -t 0 ] && printf "Setting DISPLAY=%s\n" $port >&2
        printf $port
        return 0
    fi
}

if [ -z $DISPLAY ] ; then
    export DISPLAY=$(set_display)
else
    true
    # printf "Xorg DISPLAY=%s\n" "$DISPLAY"
fi

# alias set_display='export DISPLAY=:0.0'

# ConTeXt
export PATH=$PATH:/usr/local/context/tex/texmf-linux-64/bin

# Mermaid (graphs)
export PATH=$PATH:$HOME/./node_modules/.bin

# Local binaries
export PATH=$PATH:$HOME/bin


mkv2mp4() {
    input=$1
    output=${1//.mkv/.mp4}
    time ffmpeg -i $input -vcodec copy -acodec copy $output
}

function thumb()
{
    local input=$1
    local output=thumb-$input

    convert -geometry 520x $input JPG:$output
}

teamtime() {
    now="$1" # optional time given for time zones conversion
    [ -z "$now" ] && now="$(date)" || now="$(date -d $1)"
    declare -A TZONES
    TZONES[America/Toronto]="Krishna, Jonathan, Vidun"
    TZONES[Canada/Mountain]="Gayan, John, Adam"
    TZONES[Europe/Kiev]="Sofiia, Yurii, Dmytro, Ruslan"
    TZONES[Europe/Paris]="Guillaume E., Jerome"
    TZONES[Europe/Prague]="Pavel, Martin"
    TZONES[US/Pacific]=""
    TZONES[Asia/Tokyo]=""
    TZONES[UTC]=""
    for tz in ${!TZONES[*]}; do
        printf "%-16s: %s (%s)\n" \
            "$tz" "`TZ=$tz date +%H:%M -d "$now"`" "${TZONES[$tz]}"
    done | sort | sed -e 's/()//'
}

export KUBE_EDITOR="vim"
alias xlogin='dbus-run-session -- gnome-shell --display-server --wayland'
alias dhcp_refresh='sudo dhclient -r; sudo dhclient -v enp0s3'
alias salt-states="( cd ~/Documents/tenzin/saltstack/srv/salt; tree -fC -P '*.sls' --noreport * | sed 's/.sls//g' | sed 's|\/|.|g' ) | less -r"

function pwgen() {
    local len=$1
    tr -dc A-Za-z0-9 </dev/urandom | head -c $len; echo
}

function set_cz_key(){
    setxkbmap -option grp:switch,grp:alt_shift_toggle,grp_led:scroll "cz(qwerty),us"
}
# gsettings set org.gnome.mutter workspaces-only-on-primary false

export GIT_HOME=~/Documents/GIT

# aws eks update-kubeconfig --name sxo-int

function ip_list() {
NET_DEVS=$(cat /proc/net/dev | \
    sed -ne '/:/{s/\([^:]*\).*/\1/p}' | \
    grep -vE 'lo[0-9]*|virbr[0-9]*|tun[0-9]*')

SITE=https://ifconfig.co/json

( printf "|Interface|IP Address|Location|Priority\n"
for iface in $NET_DEVS
do
    info=$(curl  --connect-timeout 1 --silent --interface $iface $SITE |\
         jq -r '"\(.ip)|\(.region_name), \(.city), \(.country)"')

    priority=$(ip route show | grep default.*$iface | rev | cut -d ' ' -f 2 | rev)
    printf "|%s|%s|%s|\n" "$iface" "$info" "$priority"
done ) | column -t -s'|'
}

function get_and_set_mtu() {
    local iface=$1
    local mtu=$2

    current=$(ifconfig $iface | sed -ne '/mtu/{s/.*mtu \([0-9]\+\)/\1/p}')
    printf "Current MTU on interface %s: %d\n" "$iface" "$current"

    if [ $current -gt $mtu ] ; then
        printf "Changing MTU to: %d\n" "$mtu"
        sudo ip link set mtu $mtu $iface
    else
        printf "Keeping current MTU: %d\n" "$current"
    fi
}

alias mtu='get_and_set_mtu enxe8ea6a89fcec 1024'

# Go lang
GOLANG_VERSION=1.25.4
export GOROOT=$HOME/bin/go-${GOLANG_VERSION}
#export GOPATH=$HOME/go
export PATH=$GOROOT/bin:$PATH #:$GOPATH/bin


