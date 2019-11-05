# Load Composer tools
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Load Node global installed binaries
export PATH="$HOME/.node/bin:$PATH"

# Use project specific binaries before global ones
export PATH="node_modules/.bin:vendor/bin:$PATH"

# Make sure coreutils are loaded before system commands
# I've disabled this for now because I only use "ls" which is
# referenced in my aliases.zsh file directly.
export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"

# export PATH=$PATH:~/.dotfiles/bin
export PATH=~/bin:~/scripts/:~/private-scripts:$PATH
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export PATH="/opt/conda/miniconda3/bin:/opt/conda/miniconda2/bin:$PATH"

. /usr/local/etc/profile.d/z.sh

# test
#############################
# CONDA
#############################
echo "about to check for conda..."
echo $(which python)
# if [ -d $CONDA_HOME/miniconda3 ]; then
#     export PATH="/opt/conda/miniconda3/bin:$PATH"
    
#     # DEBUGGING
#     echo "miniconda3 found"
#     echo $(which python)
# fi
# if [ -d $CONDA_HOME/miniconda2 ]; then
#     export PATH="/opt/conda/miniconda2/bin:$PATH"
    
#     # DEBUGGING
#     echo "miniconda2 found"
#     echo $(which python)
# fi