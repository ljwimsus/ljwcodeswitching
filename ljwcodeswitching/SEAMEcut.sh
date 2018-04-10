scriptname=$0; echo scriptname $0;
currentpath=`pwd`; echo currentpath $currentpath;

if [ $# != 2 ]; then
  echo "parameters is empty!"
  echo "Usage: $0 <transcript-absolute-path-with/> <transcript-name>"
  echo " $0 /Volumes/Data/thesis/SEAME/ NI01MAX_0101"
  exit 1;
fi


# transcript location
# format: path/NI01MAX_0101
transcriptpath=$1; echo transcriptpath $1; #absolute path to transcript folder
transcriptname=`echo ${2} | sed 's/\.txt//g' `; echo transcriptname $transcriptname; #transcript filename

utterancename=$transcriptname;

audiopath=${transcriptpath/transcript/audio}; echo audiopath $audiopath;

# use ./cut folder to store the final utterance wav and txt files
mkdir ./cut;
mkdir ./cut/${utterancename};

#multiline comments experiment
:<<\# multiline comments begins
echo "pwd is `pwd`";
cd $transcriptpath/; 
echo "cd to `pwd`";
#

 # prepare the temporary flac2wav.wav for later utterances seperation 
 # rm -f ./cut/${utterancename}.wav;
 ffmpeg -y -i ${audiopath}/${utterancename}.flac ./cut/${utterancename}.wav;

 # initial linenum is 1
 linenum=1;

echo "" > ${currentpath}/cut/${utterancename}-ffmpeg.sh;


cat ${transcriptpath}/${transcriptname}.txt | while read line ; do echo; echo line#${linenum} ${line};

# for better sorting file list, need to add zeros to the beginning of the line number for file naming
#linenum=`expr ${linenum} + 1`;
linenumber="000${linenum}"; 
linenumbername=${linenumber:((${#linenumber} - 4))}; echo $linenumbername;
#done
#:<<\### multiline comments begins

# delete the speakerID at beginning of a transcript line
singleline=${line/${transcriptname}/}; echo singleline ${singleline}; echo "";

# each transcript text
singlelinetext=${singleline//[0-9]/}; echo singlelinetext ${singlelinetext}; echo "";
# output the single transcript line to /cut/ folder
echo ${singlelinetext} > ${currentpath}/cut/${utterancename}/${utterancename}.${linenumbername}.txt

 # try to catch each transcript line's timestamps
 singlelinetimecut1=${singleline%[0-9]*}; echo singlelinetimecut1 ${singlelinetimecut1};
 singlelinetimeminus1=${#singlelinetimecut1}; echo singlelinetimeminus1 ${singlelinetimeminus1};
 singlelinetimeplus1=`expr ${singlelinetimeminus1} + 1`; echo singlelinetimeplus1 ${singlelinetimeplus1};
singlelinetime=${singleline:0:${singlelinetimeplus1}}; echo singlelinetime ${singlelinetime};

#:<<\### multiline comments begins

# try to catch each transcript line's beginning and ending position in millisecond format
 starttime=${singlelinetime%[^0-9]*}; echo starttime ${starttime}; 
 starttimelength=${#starttime}; echo starttimelength ${starttimelength};
 starttimesec=${starttime:0:${starttimelength}-3}; echo starttimesec ${starttimesec};
 starttimemillisec=${starttime:0-3:3}; echo starttimemillisec ${starttimemillisec};
starttimeposition=${starttimesec}.${starttimemillisec}; echo starttimeposition ${starttimeposition};

 endtime=${singlelinetime##*[^0-9]}; echo endtime ${endtime}; 
 endtimelength=${#endtime}; echo endtimelength ${endtimelength};
 endtimesec=${endtime:0:${endtimelength}-3}; echo endtimesec ${endtimesec};
 endtimemillisec=${endtime:0-3:3}; echo endtimemillisec ${endtimemillisec};
endtimeposition=${endtimesec}.${endtimemillisec}; echo endtimeposition ${endtimeposition};

# output the ffmpeg commands to a -ffmpeg.sh script 
#:<<\## multiline comments begins
# echo "ffmpeg -i ${transcriptname}.wav -ss ${starttimeposition} -to ${endtimeposition} -c copy ./cut/${transcriptname}.${starttimeposition}-${endtimeposition}.wav; " >> ${scriptname}-ffmpeg.sh;
# echo "ffmpeg -i ${transcriptname}.wav -ss ${starttimeposition} -to ${endtimeposition} -c copy ./cut/${transcriptname}.${linenum}.wav; " >> ${scriptname}-ffmpeg.sh;
echo "ffmpeg -y -i ${currentpath}/cut/${utterancename}.wav -ss ${starttimeposition} -to ${endtimeposition} -c copy ${currentpath}/cut/${utterancename}/${utterancename}.${linenumbername}.wav; " >> ${currentpath}/cut/${utterancename}-ffmpeg.sh;
##

 # increasing the linenum for next loop
 linenum=`expr ${linenum} + 1`;

done;

 # excute the -ffmpeg.sh to devide the single line wav to /cut/ folder
# sh ${currentpath}/cut/${utterancename}-ffmpeg.sh;
###

# remove the temporary -ffmpeg.sh and flac2wav.wav
#rm -f ${currentpath}/cut/${utterancename}-ffmpeg.sh ${currentpath}/cut/${utterancename}.wav;

 echo ""
 echo ""
 echo "back to currentpath";
 cd $currentpath; pwd;
 echo ""
 echo ""
 echo ""
 unset -v scriptname;
 unset -v currentpath;
 unset -v transcriptpath;
 unset -v transcriptname;
 unset -v utterancename;
 unset -v audiopath;
 unset -v linenum;
 unset -v linenumber;
 unset -v linenumbername;
 unset -v line;
 unset -v singleline;
 unset -v singlelinetext;
 unset -v singlelinetime;
 unset -v singlelinetimecut1;
 unset -v singlelinetimeminus1;
 unset -v singlelinetimeplus1;
 unset -v starttime;
 unset -v starttimelength;
 unset -v starttimesec;
 unset -v starttimemillisec;
 unset -v starttimeposition;
 unset -v endtime;
 unset -v endtimelength;
 unset -v endtimesec;
 unset -v endtimemillisec;
 unset -v endtimeposition;
