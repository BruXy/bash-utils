HOME_SYM_LINKS=(
    .bashrc
    .gitignore
    .tmux.conf
    .vimrc
    .vim
)

SOURCE_SYM_LINKS=(
    ../aws/aws_env.sh
)

TIME_STAMP=$(date +%Y%m%d%H%M)

function symlink_and_backup() {
    link=$1
    path=$HOME/$link
    if [ -f $path -o -d $path ] ; then
        printf "File %s exists, backup created..." $path
        mv -v $path $HOME/${link}-${TIME_STAMP}
    fi
    ln -v -s $PWD/$link $path
}

for file in ${HOME_SYM_LINKS[*]}
do
    symlink=$HOME/$file
    if [ -L $symlink ] ; then
        printf "Skipped symlink: %s\n" "$(stat --format=%N $symlink)"
    else
        symlink_and_backup $file
    fi
done

for file in ${SOURCE_SYM_LINKS[*]}
do
    symlink=$HOME/.bash_sources/$(basename $file)
    if [ -L $symlink ] ; then
        printf "Skipped symlink: %s\n" "$(stat --format=%N $symlink)"
    else
        ln -v -s $PWD/$file $symlink
    fi
done

