#!/bin/bash
# prepare dictionary for HKUST
# it is done for English and Chinese separately,
# For English, we use CMU dictionary, and Sequitur G2P
# for OOVs, while all englist phone set will concert to Chinese
# phone set at the end. For Chinese, we use an online dictionary,
# for OOV, we just produce pronunciation using Charactrt Mapping.

echo "\n    prep_dict4seame.sh begins (actually run by $0).";

. ./path.sh

set -e -o pipefail
#[ $# != 0 ] && echo "Usage: local/hkust_prepare_dict.sh" && exit 1;

train_dir=data/local/train
dev_dir=data/local/dev
dict_dir=data/local/dict
mkdir -p $dict_dir

echo "    prep_dict_step $1";
prep_dict_step=$1;

case $prep_dict_step in    #prepare dict steps
	
    0) echo "  prep_dict_step $prep_dict_step do nothing";

	;;
	1) echo "  prep_dict_step $prep_dict_step extract and split dict text.";
		echo "  Please seperately call prep_dict_step 1.1 and 1.2";
	;;
	1.1)
# extract full vocabulary
cat $train_dir/text $dev_dir/text | awk '{for (i = 2; i <= NF; i++) print $i}' |\
  perl -ape 's/ /\n/g;' | sort -u | \
  grep -v '\[LAUGHTER\]' | \
  grep -v '\[NOISE\]' |\
  grep -v '\[VOCALIZED-NOISE\]' > $dict_dir/vocab-full.txt
	;;
	1.2) echo "  split into English and Chinese.";
# split into English and Chinese
#	;;
#	1.2.1)
echo "  generate vocab-en.txt from vocab-full.txt";
#cat $dict_dir/vocab-full.txt | grep '[a-zA-Z]' > $dict_dir/vocab-en.txt ;
cat $dict_dir/vocab-full.txt | grep '^[a-zA-Z]' > $dict_dir/vocab-en.txt ;
#	;;
#	1.2.2)
echo "  generate vocab-ch.txt from vocab-full.txt";
#cat $dict_dir/vocab-full.txt | grep -v '[a-zA-Z]' | \
#  perl -CSD -Mutf8 -ane '{print if /^\p{InCJK_Unified_Ideographs}+$/;}' > $dict_dir/vocab-ch.txt ;
cat $dict_dir/vocab-full.txt | grep -v '^[a-zA-Z]' | \
  perl -CSD -Mutf8 -ane '{print if /^\p{InCJK_Unified_Ideographs}+$/;}' > $dict_dir/vocab-ch.txt ;

	;;
	1.2.3)
cat $dict_dir/vocab-full.txt | grep -v '[a-zA-Z]' | \
  perl -CSD -Mutf8 -ane '{print unless /^\p{InCJK_Unified_Ideographs}+$/;}' > $dict_dir/vocab-weird.txt ;
	;;
	1.2.4)
	echo "  split into English and Chinese done!";
	;;
	2) echo "  prep_dict_step $prep_dict_step prepare dict for english.";
	
#	;;
#	2.1)
	echo "prep_dict 2.1":
# produce pronunciations for english
if [ ! -f $dict_dir/cmudict/cmudict.0.7a ]; then
  echo "--- Downloading CMU dictionary ..."
  svn co http://svn.code.sf.net/p/cmusphinx/code/trunk/cmudict/  $dict_dir/cmudict || \
  wget -e robots=off  -r -np -nH --cut-dirs=4 -R index.html http://svn.code.sf.net/p/cmusphinx/code/trunk/cmudict/ -P $dict_dir  || exit 1
fi

if [ ! -f $dict_dir/cmudict/scripts/make_baseform.pl ] ; then
  echo "$0: $dict_dir/cmudict/scripts/make_baseform.pl does not exist!";
  exit
fi

if [ -f $dict_dir/cmudict/scripts/make_baseform.pl ] ; then
  echo "$0: $dict_dir/cmudict/scripts/make_baseform.pl exist!";
echo "cmudict is fine.";
echo "";
#  exit
fi
#	;;
#	2.2) echo "prep_dict 2.2";
#	;;
#	2.2.1)
echo "--- Striping stress and pronunciation variant markers from cmudict ..."
perl $dict_dir/cmudict/scripts/make_baseform.pl \
  $dict_dir/cmudict/cmudict.0.7a /dev/stdout |\
  sed -e 's:^\([^\s(]\+\)([0-9]\+)\(\s\+\)\(.*\):\1\2\3:' > $dict_dir/cmudict-plain.txt
	;;
	2.2.2)
echo "--- Searching for English OOV words ..."
gawk 'NR==FNR{words[$1]; next;} !($1 in words)' \
  $dict_dir/cmudict-plain.txt $dict_dir/vocab-en.txt |\
  egrep -v '<.?s>' > $dict_dir/vocab-en-oov.txt

gawk 'NR==FNR{words[$1]; next;} ($1 in words)' \
  $dict_dir/vocab-en.txt $dict_dir/cmudict-plain.txt |\
  egrep -v '<.?s>' > $dict_dir/lexicon-en-iv.txt

wc -l $dict_dir/vocab-en-oov.txt
wc -l $dict_dir/lexicon-en-iv.txt


if [ ! -f conf/g2p_model ]; then
  echo "--- Downloading a pre-trained Sequitur G2P model ..."
  wget http://sourceforge.net/projects/kaldi/files/sequitur-model4 -O conf/g2p_model
  if [ ! -f conf/g2p_model ]; then
    echo "Failed to download the g2p model!"
    exit 1
  fi
fi

	;;
	2.3)
echo "--- Preparing pronunciations for OOV words ..."
g2p=`which g2p.py`
if [ ! -x $g2p ]; then
  echo "g2p.py is not found. Checkout tools/extra/install_sequitur.sh."
  exit 1
fi
g2p.py --model=conf/g2p_model --apply $dict_dir/vocab-en-oov.txt > $dict_dir/lexicon-en-oov.txt

cat $dict_dir/lexicon-en-oov.txt $dict_dir/lexicon-en-iv.txt |\
  sort > $dict_dir/lexicon-en-phn.txt


	;;
	3) echo "  prep_dict_step $prep_dict_step prepare dict for chinese";


# produce pronunciations for chinese
if [ ! -f $dict_dir/cedict_1_0_ts_utf-8_mdbg.txt ]; then
  wget -P $dict_dir http://www.mdbg.net/chindict/export/cedict/cedict_1_0_ts_utf-8_mdbg.txt.gz
  gunzip $dict_dir/cedict_1_0_ts_utf-8_mdbg.txt.gz
fi

cat $dict_dir/cedict_1_0_ts_utf-8_mdbg.txt | grep -v '#' | awk -F '/' '{print $1}' |\
 perl -e '
  while (<STDIN>) {
    @A = split(" ", $_);
    print $A[1];
    for($n = 2; $n < @A; $n++) {
      $A[$n] =~ s:\[?([a-zA-Z0-9\:]+)\]?:$1:;
      $tmp = uc($A[$n]);
      print " $tmp";
    }
    print "\n";
  }
 ' | sort -k1 > $dict_dir/ch-dict.txt

echo "--- Searching for Chinese OOV words ..."
gawk 'NR==FNR{words[$1]; next;} !($1 in words)' \
  $dict_dir/ch-dict.txt $dict_dir/vocab-ch.txt |\
  egrep -v '<.?s>' > $dict_dir/vocab-ch-oov.txt

gawk 'NR==FNR{words[$1]; next;} ($1 in words)' \
  $dict_dir/vocab-ch.txt $dict_dir/ch-dict.txt |\
  egrep -v '<.?s>' > $dict_dir/lexicon-ch-iv.txt

wc -l $dict_dir/vocab-ch-oov.txt || true
wc -l $dict_dir/lexicon-ch-iv.txt || true



# this
unset LC_ALL
# first make sure number of characters and pinyins
# are equal
cat $dict_dir/ch-dict.txt |\
  perl -e '
  use encoding utf8;
  while (<STDIN>) {
    @A = split(" ", $_);
    $word_len = length($A[0]);
    $proun_len = @A - 1 ;
    if ($word_len == $proun_len) {print $_;}
  }
  ' > $dict_dir/ch-dict-1.txt

cat $dict_dir/ch-dict-1.txt | awk '{print $1}' | perl -ape 's/(\S)/\1\n/g;' | grep -v '^$' > $dict_dir/ch-char.txt
cat $dict_dir/ch-dict-1.txt | awk '{for(i=2; i<=NF; i++) print $i}' | perl -ape 's/ /\n/g;' > $dict_dir/ch-char-pinyin.txt
wc -l $dict_dir/ch-char.txt
wc -l $dict_dir/ch-char-pinyin.txt
paste $dict_dir/ch-char.txt $dict_dir/ch-char-pinyin.txt | sort -u > $dict_dir/ch-char-dict.txt


cat $dict_dir/ch-char-dict.txt |\
  perl -e '
  my $prev = "";
  my $out_line = "";
  while (<STDIN>) {
    @A = split(" ", $_);
    $cur = $A[0];
    $cur_py = $A[1];
    #print length($prev);
    if (length($prev) == 0) { $out_line = $_; chomp($out_line);}
    if (length($prev)>0 && $cur ne $prev) { print $out_line; print "\n"; $out_line = $_; chomp($out_line);}
    if (length($prev)>0 && $cur eq $prev) { $out_line = $out_line."/"."$cur_py";}
    $prev = $cur;
  }
  print $out_line;
  ' >  $dict_dir/ch-char-dict-1.txt

cat $dict_dir/vocab-ch-oov.txt | awk -v w=$dict_dir/ch-char-dict-1.txt \
  'BEGIN{while((getline<w)>0) dict[$1]=$2;}
   {printf("%s", $1); for (i=1; i<=length($1); i++) { py=substr($1, i, 1); printf(" %s", dict[py]); } printf("\n"); }' \
  > $dict_dir/lexicon-ch-oov.txt

cat $dict_dir/lexicon-ch-oov.txt |\
  perl -e '
  my @entry;
  my @entry1;
  while (<STDIN>) {
    @A = split(" ", $_);
    @entry = ();
    push(@entry, $A[0]);
    for($i = 1; $i < @A; $i++ ) {
      @py = split("/", $A[$i]);
      @entry1 = @entry;
      @entry = ();
      for ($j = 0; $j < @entry1; $j++) {
        for ($k = 0; $k < @py; $k++) {
          $tmp = $entry1[$j]." ".$py[$k];
          push(@entry, $tmp);
        }
      }
    }
    for ($i = 0; $i < @entry; $i++) {
      print $entry[$i];
      print "\n";
    }
  }
  ' > $dict_dir/lexicon-ch-oov1.txt

cat $dict_dir/lexicon-ch-oov1.txt $dict_dir/lexicon-ch-iv.txt |\
  awk '{if (NF > 1) print $0;}' > $dict_dir/lexicon-ch.txt

cat $dict_dir/lexicon-ch.txt | sed -e 's/U:/V/g' | sed -e 's/ R\([0-9]\)/ ER\1/g'|\
  utils/pinyin_map.pl conf/pinyin2cmu > $dict_dir/lexicon-ch-cmu.txt

cat conf/cmu2pinyin | awk '{print $1;}' | sort -u > $dict_dir/cmu
cat conf/pinyin2cmu | awk -v cmu=$dict_dir/cmu \
  'BEGIN{while((getline<cmu)) dict[$1] = 1;}
   {for (i = 2; i <=NF; i++) if (dict[$i]) print $i;}' | sort -u > $dict_dir/cmu-used
cat $dict_dir/cmu | awk -v cmu=$dict_dir/cmu-used \
  'BEGIN{while((getline<cmu)) dict[$1] = 1;}
   {if (!dict[$1]) print $1;}' > $dict_dir/cmu-not-used

gawk 'NR==FNR{words[$1]; next;} ($1 in words)' \
  $dict_dir/cmu-not-used conf/cmu2pinyin |\
  egrep -v '<.?s>' > $dict_dir/cmu-py

cat $dict_dir/cmu-py | \
  perl -e '
  open(MAPS, $ARGV[0]) or die("could not open map file");
  my %py2ph;
  foreach $line (<MAPS>) {
    @A = split(" ", $line);
    $py = shift(@A);
    $py2ph{$py} = [@A];
  }
  my @entry;
  while (<STDIN>) {
    @A = split(" ", $_);
    @entry = ();
    $W = shift(@A);
    push(@entry, $W);
    for($i = 0; $i < @A; $i++) { push(@entry, @{$py2ph{$A[$i]}}); }
    print "@entry";
    print "\n";
  }
' conf/pinyin2cmu > $dict_dir/cmu-cmu

cat $dict_dir/lexicon-en-phn.txt | \
  perl -e '
  open(MAPS, $ARGV[0]) or die("could not open map file");
  my %py2ph;
  foreach $line (<MAPS>) {
    @A = split(" ", $line);
    $py = shift(@A);
    $py2ph{$py} = [@A];
  }
  my @entry;
  while (<STDIN>) {
    @A = split(" ", $_);
    @entry = ();
    $W = shift(@A);
    push(@entry, $W);
    for($i = 0; $i < @A; $i++) {
      if (exists $py2ph{$A[$i]}) { push(@entry, @{$py2ph{$A[$i]}}); }
      else {push(@entry, $A[$i])};
    }
    print "@entry";
    print "\n";
  }
' $dict_dir/cmu-cmu > $dict_dir/lexicon-en.txt

cat $dict_dir/lexicon-en.txt $dict_dir/lexicon-ch-cmu.txt |\
  sort -u > $dict_dir/lexicon1.txt

cat $dict_dir/lexicon1.txt | awk '{ for(n=2;n<=NF;n++){ phones[$n] = 1; }} END{for (p in phones) print p;}'| \
  sort -u |\
  perl -e '
  my %ph_cl;
  while (<STDIN>) {
    $phone = $_;
    chomp($phone);
    chomp($_);
    $phone =~ s:([A-Z]+)[0-9]:$1:;
    if (exists $ph_cl{$phone}) { push(@{$ph_cl{$phone}}, $_)  }
    else { $ph_cl{$phone} = [$_]; }
  }
  foreach $key ( keys %ph_cl ) {
     print "@{ $ph_cl{$key} }\n"
  }
  ' | sort -k1 > $dict_dir/nonsilence_phones.txt  || exit 1;

( echo SIL; echo SPN; echo NSN; echo LAU ) > $dict_dir/silence_phones.txt

echo SIL > $dict_dir/optional_silence.txt

# No "extra questions" in the input to this setup, as we don't
# have stress or tone

#echo -n > $dict_dir/extra_questions.txt
cat $dict_dir/silence_phones.txt| awk '{printf("%s ", $1);} END{printf "\n";}' > $dict_dir/extra_questions.txt || exit 1;
cat $dict_dir/nonsilence_phones.txt | perl -e 'while(<>){ foreach $p (split(" ", $_)) {
  $p =~ m:^([^\d]+)(\d*)$: || die "Bad phone $_"; $q{$2} .= "$p "; } } foreach $l (values %q) {print "$l\n";}' \
 >> $dict_dir/extra_questions.txt || exit 1;


# Add to the lexicon the silences, noises etc.
(echo '!SIL SIL'; echo '[VOCALIZED-NOISE] SPN'; echo '[NOISE] NSN'; echo '[LAUGHTER] LAU';
 echo '<UNK> SPN' ) | \
 cat - $dict_dir/lexicon1.txt  > $dict_dir/lexicon.txt || exit 1;


export LC_ALL=C
echo "$0: Done"

	;;
	*) echo "  It seems you didn't provide the prep_dict_step.";
esac

echo "    prep_dict4seame.sh ends (actually run by $0).\n";