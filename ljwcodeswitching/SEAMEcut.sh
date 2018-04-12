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
transcriptpath=`echo ${1} | sed 's/\.txt//g' | sed 's/\.flac//g' | sed 's/\.wav//g' | sed 's/\/$//g`; echo transcriptpath $1; #absolute path to transcript folder
transcriptname=`echo ${2} | sed 's/\.txt//g' | sed 's/\.flac//g' | sed 's/\.wav//g'`; echo transcriptname $transcriptname; #transcript filename

utterancename=$transcriptname; echo ""; echo "ffmpeg processing for ${utterancename} begins!"; echo "";

audiopath=${transcriptpath/transcript/audio}; echo audiopath $audiopath;

# should the following experiment remove in higher versions
#multiline comments experiment
:<<\# multiline comments begins
echo "pwd is `pwd`";
cd $transcriptpath/; 
echo "cd to `pwd`";
#


# use ./cut folder to store the final utterance wav and txt files
 cutfolder = "cut";
####### rm ./${cutfolder}; # delete old to create new 
####### the above line is an extremely dangerous operation!!! when ${cutfolder} misteriously become empty, it delete everything in ./ path.
if [ $cutfolder == "" ]; then
	 echo "WHAT'S WRONG??? \$cutfolder is EMPTY!!! ARE YOU SERIOUSLY to rm -rf ./ ???"; 
	exit 1;
else
### rm -rf ./${cutfolder}; # delete old to create new
### be careful this usage!!! the safe way is just rm $cutfolder without ./ 
### mkdir ./${cutfolder};
### mkdir ./${cutfolder}/${utterancename};
rmtrash ${cutfolder};
mkdir ${cutfolder};
mkdir ${cutfolder}/${utterancename};
fi
# ./cut is used from v1.0.x

# use ./temp folder to store the temporary files
 tempfolder = "cut"; # used from v2.0
 #tempfolder = "temp"; # to be used in higher versions
####### rm ./${tempfolder}; # delete old to create new 
####### the above line is an extremely dangerous operation!!! when ${cutfolder} misteriously become empty, it delete everything in ./ path.
if [ $tempfolder == "" ]; then
	 echo "WHAT'S WRONG??? \$tempfolder is EMPTY!!!ARE YOU SERIOUSLY to rm -rf ./ ???"; 
	exit 1;
else
### rm -rf ./${tempfolder}; # delete old to create new
### be careful this usage!!! the safe way is just rm $tempfolder without ./
### mkdir ./${tempfolder}; 
rmtrash ${tempfolder};
mkdir ${tempfolder};
fi
# ./temp will be used in version higher than v3.0


# create ffmepg.sh for parallel execution

#echo "" > ${currentpath}/${cutfolder}/ffmepg-flac2wav.sh # no longer used in loop
#echo "" > ${currentpath}/${cutfolder}/ffmepg-splitwav.sh # no longer used in loop
# the above 2 lines are wrong to run in while loop!!!
# should remove in higher versions

# prepare the temporary flac2wav.wav for later utterances seperation 
# this operation is no longer excute in this script directly but export to the ${currentpath}/${tempfolder}/ffmepg-flac2wav.sh for parallel executions
  # rm -f ./${cutfolder}/${utterancename}.wav;
  # ffmpeg -y -i ${audiopath}/${utterancename}.flac ./${cutfolder}/${utterancename}.wav;
#
# on v1.0.1 test, the above line cause $1 and $2 confusing
# should move this operations to ${utterancename}-ffmpeg-flac2wav.sh as below:
#echo "ffmpeg -y -i ${audiopath}/${utterancename}.flac ./${cutfolder}/${utterancename}.wav;" > ${currentpath}/${cutfolder}/${utterancename}-ffmpeg-flac2wav.sh;
#
# fixed the ./${cutfolder}/${utterancename}.wav problem
#echo "ffmpeg -y -i ${audiopath}/${utterancename}.flac ${currentpath}/${cutfolder}/${utterancename}.wav;" >> ${currentpath}/${cutfolder}/${utterancename}-ffmpeg-flac2wav.sh;

# seprated the flac2wav operations with spiltwav operations in v1.0.5
echo "ffmpeg -y -i ${audiopath}/${utterancename}.flac ${currentpath}/${tempfolder}/${utterancename}.wav 2>&1 | tee ${currentpath}/${tempfolder}/${utterancename}.wav.log.txt ;" >> ${currentpath}/${tempfolder}/ffmepg-flac2wav.sh;

 # initial linenum is 1
 linenum=1;

# while loop for singleline transcription's speration
# in v2.0.0 use sed to remove tab to solve the starttime recognizing problem
  #cat ${transcriptpath}/${transcriptname}.txt | while read line ; do echo; echo line#${linenum} ${line};
  sed 's/[[:space:]]/\ /g' ${transcriptpath}/${transcriptname}.txt | while read line ; do echo; echo line#${linenum} ${line};

# for better sorting file list, need to add zeros to the beginning of the line number for file naming
  #linenum=`expr ${linenum} + 1`;
  linenumber="000${linenum}"; 
  linenumbername=${linenumber:((${#linenumber} - 4))}; echo $linenumbername;
#done # used for testing adding zero as above describted only. the below multiline comments is related.

#:<<\### multiline comments begins, to filter out the whole transcript recognition within the while loop

# delete the speakerID at beginning of a transcript line
singleline=${line/${transcriptname}/}; echo singleline ${singleline}; echo "";

# catching each transcript line's text
singlelinetext=${singleline//[0-9]/}; echo singlelinetext ${singlelinetext}; echo "";

# from v2.0.0 the output of single transcript line text move to the end of the while loop
# output the single transcript line to /${cutfolder}/ folder
#echo ${singlelinetext} > ${currentpath}/${cutfolder}/${utterancename}/${utterancename}.${linenumbername}.txt

 # try to catch each transcript line's timestamps
 singlelinetimecut1=${singleline%[0-9]*}; echo singlelinetimecut1 ${singlelinetimecut1};
 singlelinetimeminus1=${#singlelinetimecut1}; echo singlelinetimeminus1 ${singlelinetimeminus1};
 singlelinetimeplus1=`expr ${singlelinetimeminus1} + 1`; echo singlelinetimeplus1 ${singlelinetimeplus1};
singlelinetime=${singleline:0:${singlelinetimeplus1}}; echo singlelinetime ${singlelinetime};

#:<<\### multiline comments begins, to filter out the following transcript timestamp recognition within the while loop

# catching each transcript line's beginning and ending position in millisecond format
# on v1.0.2 the following lines will crash when starttime is 0 !!! 
# an if test is need!!!
 starttime=${singlelinetime%[^0-9]*}; echo starttime ${starttime};
    if [ ${starttime} == 0 ]; then # adding if test to avoid crashing
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
#
#:<<\## multiline comments begins
# echo "ffmpeg -i ${transcriptname}.wav -ss ${starttimeposition} -to ${endtimeposition} -c copy ./${cutfolder}/${transcriptname}.${starttimeposition}-${endtimeposition}.wav; " >> ${scriptname}-ffmpeg-splitwav.sh;
# echo "ffmpeg -i ${transcriptname}.wav -ss ${starttimeposition} -to ${endtimeposition} -c copy ./${cutfolder}/${transcriptname}.${linenum}.wav; " >> ${scriptname}-ffmpeg-splitwav.sh;
# echo "ffmpeg -y -i ${currentpath}/${cutfolder}/${utterancename}.wav -ss ${starttimeposition} -to ${endtimeposition} -c copy ${currentpath}/${cutfolder}/${utterancename}/${utterancename}.${linenumbername}.wav; " >> ${currentpath}/${tempfolder}/${utterancename}-ffmpeg-splitwav.sh;
#
# in v2.0.0 the -ffmpeg-splitwav.sh script is prepared for parallel excute the all the single line ffmpeg operations
echo "ffmpeg -y -i ${currentpath}/${tempfolder}/${utterancename}.wav -ss ${starttimeposition} -to ${endtimeposition} -c copy ${currentpath}/${cutfolder}/${utterancename}/${utterancename}.${linenumbername}.wav 2>&1 | tee -a ${currentpath}/${tempfolder}/${utterancename}-ffmpeg-splitwav.sh.log.txt"; " >> ${currentpath}/${tempfolder}/${utterancename}-ffmpeg-splitwav.sh;
##

# the below ffmepg-splitwav.sh couldnot perform correctly in v1.x version, so it might be removed in higher versions.
#
# generating ${currentpath}/${cutfolder}/${utterancename}-ffmpeg-splitwav.sh list for parallel execution
echo "${currentpath}/${tempfolder}/${utterancename}-ffmpeg-splitwav.sh 2>&1 | tee -a ${currentpath}/${tempfolder}/${utterancename}-ffmpeg-splitwav.sh.log.txt" >> ${currentpath}/${tempfolder}/ffmepg-splitwav.sh



# from v2.0.0 the output of single transcript line text move to here, the end of the while loop
# output the single transcript line to /${cutfolder}/ folder
echo ${singlelinetext} > ${currentpath}/${cutfolder}/${utterancename}/${utterancename}.${linenumbername}.txt



### the multiline comment ending tag for testing "adding zero to linenumber" and " hidding starttime/endingtime catching" 

 # increasing the linenum for next loop
 linenum=`expr ${linenum} + 1`;

done;

 # from v1.1.1 remove the following ffmpeg-splitwav.sh execution within the script and suggest to run it by an external script calling
 # excute the -ffmpeg-splitwav.sh to devide the single line wav to /${cutfolder}/ folder
#sh ${currentpath}/${cutfolder}/${utterancename}-ffmpeg-splitwav.sh;
 # in v1.0.4 found that excuting ${utterancename}-ffmpeg-splitwav.sh will cause $1 $2 confusing


# no longer perform this rm operation from v1.1.1
# remove the temporary -ffmpeg-splitwav.sh and flac2wav.wav
#rm -f ${currentpath}/${cutfolder}/${utterancename}-ffmpeg-splitwav.sh ${currentpath}/${cutfolder}/${utterancename}.wav;



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
