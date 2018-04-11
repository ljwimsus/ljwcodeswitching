#!/bin/bash

# the 1.0 version fail in following issues:
# 1. cannot handle starttime and endtime length shorter than 6 digits
# 2. parallel pipeline cannot handle xxx.sh but just parallel single ffmpeg operation
#
# the 2.0 version will try to cut out or improve the above features

scriptname=$0; echo scriptname $0;
currentpath=`pwd`; echo currentpath $currentpath;

if [ $# != 2 ]; then
  echo "parameters is empty!"
  echo "Usage: $0 <transcript-absolute-path-with/> <transcript-name>"
  echo " $0 /Volumes/Data/thesis/SEAME/ NI01MAX_0101"
  echo ""
  echo "Be awared that the audio list should have one empty line at the end!"
  echo "to get the last line of the audio list!"
  echo ""
  exit 1;
fi


# transcript location
# format: path/NI01MAX_0101
transcriptpath=`echo ${1} | sed 's/\.txt//g' | sed 's/\.flac//g' | sed 's/\.wav//g'`; echo transcriptpath $1; #absolute path to transcript folder
transcriptname=`echo ${2} | sed 's/\.txt//g' | sed 's/\.flac//g' | sed 's/\.wav//g'`; echo transcriptname $transcriptname; #transcript filename

utterancename=$transcriptname; echo ""; echo "ffmpeg processing for ${utterancename} begins!"; echo "";

audiopath=${transcriptpath/transcript/audio}; echo audiopath $audiopath;

# use ./cut folder to store the final utterance wav and txt files
mkdir ./cut;
mkdir ./cut/${utterancename};

# create ffmepg.sh4parallel.sh for parallel excution
#echo "" > ${currentpath}/cut/ffmepg-flac2wav.sh4parallel.sh
#echo "" > ${currentpath}/cut/ffmepg-splitwav.sh4parallel.sh
# the above 2 lines are wrong to run in while loop!!!

#multiline comments experiment
:<<\# multiline comments begins
echo "pwd is `pwd`";
cd $transcriptpath/; 
echo "cd to `pwd`";
#


 # prepare the temporary flac2wav.wav for later utterances seperation 
 # rm -f ./cut/${utterancename}.wav;
# ffmpeg -y -i ${audiopath}/${utterancename}.flac ./cut/${utterancename}.wav;
# on v1.0.1 test, the above line cause $1 and $2 confusing
# should move this operations to ${utterancename}-ffmpeg-flac2wav.sh as below:
#echo "ffmpeg -y -i ${audiopath}/${utterancename}.flac ./cut/${utterancename}.wav;" > ${currentpath}/cut/${utterancename}-ffmpeg-flac2wav.sh;
# fixed the ./cut/${utterancename}.wav problem
#echo "ffmpeg -y -i ${audiopath}/${utterancename}.flac ${currentpath}/cut/${utterancename}.wav;" >> ${currentpath}/cut/${utterancename}-ffmpeg-flac2wav.sh;
# seprated the flac2wav operations
echo "ffmpeg -y -i ${audiopath}/${utterancename}.flac ${currentpath}/cut/${utterancename}.wav;" >> ${currentpath}/cut/ffmepg-flac2wav.sh4parallel.sh;

 # initial linenum is 1
 linenum=1;

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
# on v1.0.2 the following lines will crash when starttime is 0 !!! 
# an if test is need!!!
 starttime=${singlelinetime%[^0-9]*}; echo starttime ${starttime};
    if [ ${starttime} == 0 ]; then
    	starttimeposition = 0;
    else
 starttimelength=${#starttime}; echo starttimelength ${starttimelength};
 starttimesec=${starttime:0:${starttimelength}-3}; echo starttimesec ${starttimesec};
 starttimemillisec=${starttime:0-3:3}; echo starttimemillisec ${starttimemillisec};
starttimeposition=${starttimesec}.${starttimemillisec}; echo starttimeposition ${starttimeposition};
    fi
 endtime=${singlelinetime##*[^0-9]}; echo endtime ${endtime}; 
 endtimelength=${#endtime}; echo endtimelength ${endtimelength};
 endtimesec=${endtime:0:${endtimelength}-3}; echo endtimesec ${endtimesec};
 endtimemillisec=${endtime:0-3:3}; echo endtimemillisec ${endtimemillisec};
endtimeposition=${endtimesec}.${endtimemillisec}; echo endtimeposition ${endtimeposition};

# output the ffmpeg commands to a -ffmpeg-splitwav.sh script 
#:<<\## multiline comments begins
# echo "ffmpeg -i ${transcriptname}.wav -ss ${starttimeposition} -to ${endtimeposition} -c copy ./cut/${transcriptname}.${starttimeposition}-${endtimeposition}.wav; " >> ${scriptname}-ffmpeg-splitwav.sh;
# echo "ffmpeg -i ${transcriptname}.wav -ss ${starttimeposition} -to ${endtimeposition} -c copy ./cut/${transcriptname}.${linenum}.wav; " >> ${scriptname}-ffmpeg-splitwav.sh;
echo "ffmpeg -y -i ${currentpath}/cut/${utterancename}.wav -ss ${starttimeposition} -to ${endtimeposition} -c copy ${currentpath}/cut/${utterancename}/${utterancename}.${linenumbername}.wav; " >> ${currentpath}/cut/${utterancename}-ffmpeg-splitwav.sh;
##
# generating ${currentpath}/cut/${utterancename}-ffmpeg-splitwav.sh list for parallel excution
echo "${currentpath}/cut/${utterancename}-ffmpeg-splitwav.sh 2>&1 | tee -a ${currentpath}/cut/${utterancename}-ffmpeg.log.txt 2>&1" >> ${currentpath}/cut/ffmepg-splitwav.sh4parallel.sh

 # increasing the linenum for next loop
 linenum=`expr ${linenum} + 1`;

done;

 # excute the -ffmpeg-splitwav.sh to devide the single line wav to /cut/ folder
#sh ${currentpath}/cut/${utterancename}-ffmpeg-splitwav.sh;
 # in v1.0.4 found that excuting ${utterancename}-ffmpeg-splitwav.sh will cause $1 $2 confusing
 # remove this line and suggest to run it by an external script calling 

###

# remove the temporary -ffmpeg-splitwav.sh and flac2wav.wav
#rm -f ${currentpath}/cut/${utterancename}-ffmpeg-splitwav.sh ${currentpath}/cut/${utterancename}.wav;

 echo ""
 echo ""
 echo "back to currentpath";
 cd $currentpath; pwd;
 echo ""
 echo ""; 
 echo "ffmpeg processing for ${utterancename} ends!";
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
