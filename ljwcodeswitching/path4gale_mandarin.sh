#/**
# * create in eclipse which will link to gale_mandarin/path.sh
# */

#./path.sh: line 1: /Applications: is a directory
#./path.sh: line 2: RESULTS: command not found
#./path.sh: line 3: conf/: is a directory

# the above is the console error msg for unfix .js /* */ comments
 
echo "begin of path.sh"

export KALDI_ROOT=~/kaldi/kaldi
export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/tools/kaldi_lm:$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
# :' . $KALDI_ROOT/tools/config/common_path.sh '
# ＃ . $KALDI_ROOT/tools/env.sh #＃ is a Chinese character ＃ not ANSCI #
. $KALDI_ROOT/tools/config/common_path.sh
echo "call of common_path.sh"
. $KALDI_ROOT/tools/env.sh
echo "call of env.sh"

export LC_ALL=C

echo "end of path.sh"

echo "actually run from path4gale_mandarin.js"