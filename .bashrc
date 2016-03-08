#Add this before any command to run to send it's output to an xvfb buffer instead of your normal screen
alias hide='xvfb-run -a --server-args="-screen 0, 2048x720x24"'
alias mci="mvn clean install"
#Lets you do cat | xclip to copy standard out to your clipboard
alias xclip="xclip -selection clipboard"

notify () {
        "$@"; notify-send -t 0 "$@ finished running"
}

export PS1='[\[\e[0;33m\]\u@\h\[\e[0m\] \w$(__git_ps1 " (\[\e[1;34m\]%s\[\e[0m\])")]$ '

#What ports are things running on
ports () {
        netstat -tulpn | tail -n +3 | sort -k 3,7 -k 6,6 | awk '{print $4"\t\t"$7}' | grep -vE ':::|udp' | grep -E '0\.0\.0\.0:'
}

#Docker stuff
#connect to a docker container, pass the container's id as an argument
cocker () {
    docker exec -i -t "$@" bash
}
#kill all your docker containers
alias kocker='docker rm -f $(docker ps -aq)'

#Git stuff
#Update all branches, delete any that have already been merged, including the one that you're on. Will not delete master.
gclean () {
        CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        BRANCHES=($(git branch | cut -c 3- | grep -v master))
        git checkout master > /dev/null 2>&1
        for branch in "${BRANCHES[@]}"
        do
                echo "Fetching ${branch}"
                git checkout ${branch} > /dev/null 2>&1
                git pull --ff-only > /dev/null 2>&1
        done

        if [ "$(git branch --merged origin/master | grep -v master | grep -v $(git rev-parse --abbrev-ref HEAD) | wc -l)" -gt "0" ]; then
                git branch --merged origin/master | cut -c 3- | grep -v master | grep -v $(git rev-parse --abbrev-ref HEAD) | xargs -n 1 echo "Pruning branch"
                git branch --merged origin/master | cut -c 3- | grep -v master | grep -v $(git rev-parse --abbrev-ref HEAD) | xargs git branch -d > /dev/null 2>&1
        else
                echo "No branches to prune"
        fi

        #Zero means that the branch exists
        git show-ref --verify --quiet "refs/heads/${CURRENT_BRANCH}" > /dev/null 2>&1
        CURRENT_BRANCH_EXISTS=$?

        if [[ ${CURRENT_BRANCH_EXISTS} == 0 ]]; then
                git checkout ${CURRENT_BRANCH} > /dev/null 2>&1
        else
                echo "The branch you were on, ${CURRENT_BRANCH} was deleted, returning you to master"
        fi
}

#List all files without seeing the contents of the change. Defaults to showing you what's on HEAD. Pass a Git commit identifier if you want to see something else.
gfiles () {
        if [ -n "$1" ]; then
                git diff-tree --no-commit-id --name-only -r "$1"
        else
                git diff-tree --no-commit-id --name-only -r HEAD
        fi
}

