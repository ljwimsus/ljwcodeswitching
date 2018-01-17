echo ""
echo "begin of path4seame.sh (actually calls from $0)"
echo ""

systemname=`uname -s`;

if [ $systemname = Linux ]; then echo ""; echo "It's on Linux!"; echo "";
	export SEAME_ROOT=/projekte/slu/Data/SEAME
	export KALDI_ROOT=/mount/studenten/team-lab-phonetics/2017/groups/codeswitching/kaldi-trunk		
else
	export SEAME_ROOT=~/SEAME
	export KALDI_ROOT=~/kaldi
fi
	export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/tools/kaldi_lm:$PWD:$PATH
	[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
# :' . $KALDI_ROOT/tools/config/common_path.sh '
# ＃ . $KALDI_ROOT/tools/env.sh #＃ is a Chinese character ＃ not ANSCI #
	echo "    call of common_path.sh"
	. $KALDI_ROOT/tools/config/common_path.sh
	echo "    end of common_path.sh"
	echo "    call of env.sh"
	. $KALDI_ROOT/tools/env.sh
	echo "    end of env.sh"

	export LC_ALL=C

echo "end of path4seame.sh (actually called from $0)."
echo ""