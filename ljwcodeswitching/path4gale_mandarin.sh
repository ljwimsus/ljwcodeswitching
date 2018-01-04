/**
 * create in eclipse which will link to gale_mandarin
 */
 
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