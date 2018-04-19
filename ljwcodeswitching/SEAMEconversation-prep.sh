#!/bin/bash

echo ""

scriptname=$0; echo scriptname $0;
currentpath=`pwd`; echo currentpath $currentpath;

if [ $# != 3 ]; then
  echo ""
  echo "parameters is empty!"
  echo ""
  echo "Usage: $0 <audio-absolute-path-with/> <utterance-name> <transcript-absolute-path-with/>"
  echo ""
  echo "e.g.:"
  echo " $0 /projekte/slu/Data/SEAME/data/conversation/audio/ 01NC01FBX_0101 /projekte/slu/Data/SEAME/data/conversation/transcript/"
  echo ""
  echo "or:"
  echo " $0 /Volumes/Data/thesis/SEAME/data/conversation/audio/ 01NC01FBX_0101 /Volumes/Data/thesis/SEAME/data/conversation/transcript/"
  echo ""
  echo "Be awared that the audio list should have one empty line at the end!"
  echo "to get the last line of the audio list!"
  echo ""
  exit 1;
fi

echo ""


# utterance name, audio and transcript locations
audiopath=`echo ${1}|sed 's/\.txt//g'|sed 's/\.flac//g'|sed 's/\.wav//g'|sed 's/\/$//g'`; echo audiopath $audiopath; #absolute path to transcript folder
utterancename=`echo ${2}|sed 's/\.txt//g'|sed 's/\.flac//g'|sed 's/\.wav//g'`; echo utterancename $utterancename; #transcript filename
transcriptpath=`echo ${3}|sed 's/\.txt//g'|sed 's/\.flac//g'|sed 's/\.wav//g'|sed 's/\/$//g'`; echo transcriptpath $transcriptpath; #absolute path to transcript folder

echo "";
echo "ffmpeg processing for ${utterancename} begins!"; 
echo "";

# prepare the temporary flac2wav.sh to convert the flac to wav

#echo "ffmpeg -y -i ${audiopath}/${utterancename}.flac ${currentpath}/${utterancename}.wav 2>&1 | tee ${currentpath}/${utterancename}.wav.log.txt ;" >> ${currentpath}/ffmepg-flac2wav.sh;

 # initial linenum is 1
 linenum=1;
 loopnum=1;

echo "while read line loop begins"; echo ""; echo "";
# while loop for singleline transcription's speration
  cat ${transcriptpath}/${utterancename}.txt | while read line ; do echo "while read line loop enters"; echo ""; 

if [[ $line != "" ]]; then
   	echo "line is not empty, continue to process:"; echo "";	
  	echo line#${linenum} ${line};

# for better sorting file list, need to add zeros to the beginning of the line number for file naming
  #linenum=`expr ${linenum} + 1`;
  linenumber="000${linenum}"; 
  linenumbername=${linenumber:((${#linenumber} - 4))}; echo ""; echo linenumbername $linenumbername; echo "";


 echo "";
 echo ""; echo "the script should by pass the following multiline comments for the singleline tests";
:<<\#####
 echo ""; echo "this line at the begining of singleline tests should be by passed";
 echo "";

echo "line/${utterancename}"; echo "";
singlelinetest1=${line/NI01FAX_0101/,}; echo singlelinetest1 ${singlelinetest1};
singlelinetest2=${line/NI02FAX_0101/,}; echo singlelinetest2 ${singlelinetest2};
 echo "";

singleline=${line/${utterancename}/}; echo singleline ${singleline}; echo "";
echo \$0 $0; echo "";
echo \$1 $1; echo "";
echo \$2 $2; echo "";
echo \$3 $3; echo "";
echo \$4 $4; echo "";
echo \$5 $5; echo "";

echoignoretabspaceinhead=`echo$singleline`;
echo$echoignoretabspaceinhead;
echo "$echoignoretabspaceinhead";

echo 					this works!!!;


echo$singleline works!!!!
echo$singleline; echo "THIS WORKS!!!!!!!!!!!!!"
echo "$singleline;";
echo "$singleline;";
echo "$singleline";
echo "$singleline";
echo"$singleline";
echo"$singleline";

echo "awk \$singleline"; 
echo $singleline | awk '{printf("%s", $0)}'; echo "";
echo $singleline | sed 's/^[ \t]//g';
echo $singleline | sed 's/^[ ]//g';
echo$singleline | sed 's/^[	]+//g';
singlelinewithouttabspace=`echo $singleline|sed 's/^[ \t]+//g'`;
echo \$singlelinewithouttabspace; 
echo $singlelinewithouttabspace; 

singleline=${line/${utterancename}/}; echo ${singleline} > ./test.txt;
echo "awk \$singleline"; echo $singleline|awk '{printf("%s", $0)}' >> ./test.txt; 
echo $singleline | sed 's/^[ \t]//g' >> ./test.txt;
singlelinewithouttabspace=`echo $singleline|sed 's/^[ \t]+//g'`; 
echo $singlelinewithouttabspace >> ./test.txt; 


 echo "";
 echo ""; echo "this line before the ending of singleline tests should be by passed";
#####
 echo ""; echo "this line after the ending of singleline tests should be displayed"; 
 echo "";



# delete the speakerID at the beginning of a transcript line
echo "delete the speakerID at the beginning of a transcript line:";
#echo ${line/${utterancename}/}
#echo${line/${utterancename}/}
#echo "${line/${utterancename}/}"
#echo"${line/${utterancename}/}"
#echo "";
#echo ${line/${utterancename}/};
#echo${line/${utterancename}/} # THIS ONE WORKS!!!
#echo "${line/${utterancename}/}";
#echo"${line/${utterancename}/}";
echo "";
#singleline=`echo${line/${utterancename}/}`;
#`echo${line/${utterancename}/}`;
 #if [ $? != 0 ]; then echo $?; fi 
if [[ ! `echo${line/${utterancename}/}` ]]; then 
	echo "Something WRONG!!! The script will exit 1!!! ";
	echo "The $utterancename didn't exist in this line!!!";
	echo "Please check the corpus in transcript $transcriptpath/$utterancename of line $linenum"; 
	exit 1;
else
 singleline=`echo${line/${utterancename}/}`;
fi
#echo singleline; 
#echo "${singleline}"; 
#echo"${singleline}";
#echo ${singleline};
#echo${singleline};
echo "";

#singleline1=${line/${utterancename}/}; echo "singleline1 ${singleline1}"; echo "";
#singleline2=${line/${utterancename}/}; echo singleline2 ${singleline2}; echo "";
#singlelinewithoututterancename1=${line/${utterancename}/}; echo "singlelinewithoututterancename1 ${singlelinewithoututterancename1}"; echo "";
#singlelinewithoututterancename2=${line/${utterancename}/}; echo singlelinewithoututterancename2 ${singlelinewithoututterancename2}; echo "";
#singleline3=`echo ${line/${utterancename}/}`;echo "singleline3"; echo$singleline3;

# catching each transcript line's text
#singlelinetextwithoutdigitswithintranscript=${singleline//[0-9]/}; echo "singlelinetextwithoutdigitswithintranscript ${singlelinetextwithoutdigitswithintranscript}";
#
#the above line is wrong, it deletes all the digits within the line, includeing those in the transcript text
#
singlelinetext=`echo $singleline|sed 's/^[ \t0-9]*//g'`; echo "singlelinetext $singlelinetext";

#echo singleline $singleline; echo "";
#echo singlelinelenghth ${#singleline}; echo "";
#echo singlelinetextlenghth ${#singlelinetext}; echo "";
#echo "singlelinelenghth - singlelinetextlenghth"; echo `expr ${#singleline} - ${#singlelinetext}`; echo ""
#singlelinetimetest1=${singleline/${singlelinetext}/}; echo "singlelinetimetest1 ${singlelinetimetest1}"; echo "";
#singlelinetimetest2=${singleline:0:`expr ${#singleline} - ${#singlelinetext}`}; echo singlelinetimetest2 ${singlelinetimetest2}; echo "";
#singlelinetimetest3=${singleline:4:`expr ${#singleline}-${#singlelinetext}+1`}; echo singlelinetimetest3 ${singlelinetimetest3}; echo "";
#singlelinetimetest4=${singleline:4:2}; echo singlelinetimetest4 ${singlelinetimetest4}; echo "";


 # try to catch each transcript line's timestamps
 #singlelinetimecut1=${singleline%[0-9]*}; echo singlelinetimecut1 ${singlelinetimecut1};
 #singlelinetimeminus1=${#singlelinetimecut1}; echo singlelinetimeminus1 ${singlelinetimeminus1};
 #singlelinetimeplus1=`expr ${singlelinetimeminus1} + 1`; echo singlelinetimeplus1 ${singlelinetimeplus1};
#singlelinetime=${singleline:0:${singlelinetimeplus1}}; echo singlelinetime ${singlelinetime};
#the above methods is no longer used from v1.0.0
singlelinetime=${singleline/${singlelinetext}/}; echo "singlelinetime ${singlelinetime}"; echo "";

# catching each transcript line's beginning and ending position in millisecond format
# on v1.0.2 the following lines will crash when starttime is 0 !!! 
# an if test is need!!!
 starttime=${singlelinetime%[^0-9]*\ }; echo starttime ${starttime};
#if [ ${starttime} != "0" ]; then # adding if test to avoid crashing
#if [[ $starttime != "0" ]] ; then # double [[ ]] will ignore the spaces in $starttime
 #starttimelength=${#starttime}; echo starttimelength ${starttimelength};
 #starttimesec=${starttime:0:${starttimelength}-3}; echo starttimesec ${starttimesec};
 #starttimemillisec=${starttime:0-3:3}; echo starttimemillisec ${starttimemillisec};
 
#starttimenospace=`echo $starttime | sed 's/[[:space:]]//g'`; echo "\$starttimenospace $starttimenospace";
starttimenospace=`echo $starttime|sed 's/[^0-9]//g'`; echo "\$starttimenospace $starttimenospace"; #GOOOOOOOD!!!FINALLLY KICK OFF THE SPACES IN THE DIGITS!!!
if [[ $starttimenospace != 0 ]]; then
 #if [ $starttimenospace != 0 ]; then echo "\$starttimenospace without spaces!"; fi
 starttimetest1=`expr ${starttimenospace} / 1000`; echo "\$starttimetest1 $starttimetest1 is a digital number without space.";
 starttimetest2=`echo "sclae=2; $starttimenospace / 1000" | bc`; echo "\$starttimetest2 $starttimetest2 is a digital number without space.";
 starttimetest3=`awk 'BEGIN{printf "%.3f\n",('$starttimenospace'/1000)}'`; echo "\$starttimetest3 $starttimetest3 is a digital number without space.";
starttimeposition=`awk 'BEGIN{printf "%.3f\n",('$starttimenospace'/1000)}'`;echo starttimeposition ${starttimeposition};
#in v2.0.6 use awk to get the starttimeposition

# from v2.0.9 no longer use the following string     
 #starttimelength=${#starttimenospace}; echo starttimelength ${starttimelength};
 #starttimesec=${starttime:0:${starttimelength}-3}; echo starttimesec ${starttimesec};
 #starttimemillisec=${starttime:0-3:3}; echo starttimemillisec ${starttimemillisec};
#starttimeposition=${starttimesec}.${starttimemillisec}; echo starttimeposition ${starttimeposition};

else
 #starttimeposition = 0; # Don't put spaces around the = in assignments.
starttimeposition=0; echo starttimeposition=0;
fi # in v2.0.5 change from [ ${starttime} == 0 ]; to [ ${starttime} != 0 ]; to avoid == style problem

 endtime=${singlelinetime#*[^0-9]}; echo endtime ${endtime}; 

#endtimenospace=`echo $endtime | sed 's/[[:space:]]//g'`; echo "\$endtimenospace $endtimenospace";
endtimenospace=`echo $endtime | sed 's/[^0-9]//g'`; echo "\$endtimenospace $endtimenospace"; #GOOOOOOOD!!!FINALLLY KICK OFF THE SPACES IN THE DIGITS!!!

 if [ $endtimenospace != 0 ]; then echo "\$endtimenospace without spaces!"; fi
 endtimetest1=`expr ${endtimenospace} / 1000`; echo "\$endtimetest1 $endtimetest1 is a digital number without space.";
 endtimetest2=`echo "sclae=2; $endtimenospace / 1000" | bc`; echo "\$endtimetest2 $endtimetest2 is a digital number without space.";
 endtimetest3=`awk 'BEGIN{printf "%.3f\n",('$endtimenospace'/1000)}'`; echo "\$endtimetest3 $endtimetest3 is a digital number without space.";
endtimeposition=`awk 'BEGIN{printf "%.3f\n",('$endtimenospace'/1000)}'`; echo endtimeposition ${endtimeposition};
#in v2.0.6 use awk to get the endtimeposition
  
 #endtimelength=${#endtimenospace}; echo endtimelength ${endtimelength};
 #endtimesec=${endtime:0:${endtimelength}-3}; echo endtimesec ${endtimesec};
 #endtimemillisec=${endtime:0-3:3}; echo endtimemillisec ${endtimemillisec};
#endtimeposition=${endtimesec}.${endtimemillisec}; echo endtimeposition ${endtimeposition};



# output the ffmpeg commands to a -ffmpeg-splitwav.sh script 
#
# in v2.0.0 the -ffmpeg-splitwav.sh script is prepared for parallel excute the all the single line ffmpeg operations

#echo "ffmpeg -y -i ${currentpath}/${tempfolder}/${utterancename}.wav -ss ${starttimeposition} -to ${endtimeposition} -c copy ${currentpath}/${cutfolder}/${utterancename}/${utterancename}.${linenumbername}.wav 2>&1 | tee -a ${currentpath}/${tempfolder}/${utterancename}-ffmpeg-splitwav.sh.log.txt;" >> ${currentpath}/${tempfolder}/${utterancename}-ffmpeg-splitwav.sh;


# from v2.0.0 the output of single transcript line text move to here, the end of the while loop
# output the single transcript line to /${cutfolder}/ folder
#echo ${singlelinetext} > ${currentpath}/${cutfolder}/${utterancename}/${utterancename}.${linenumbername}.txt



# echo ""; 
# echo ""; echo "this line within the while loop should be by passed";
########
# echo ""; echo "this line after the while loop should be displayed";
# echo "";

echo "";
 # increasing the linenum for next loop
 linenum=`expr ${linenum} + 1`; echo linenum+1; echo linenum $linenum;

else
	echo "this is an empty line, linenum would not increase."; echo "";
fi

echo ""; echo "while read line loop enter next loop"; echo "";

loopnum=`expr $loopnum + 1`; echo loopnum $loopnum;

if [[ $loopnum != $linenum ]]; then echo "caution!!! \$loopnum not equal to \$linenum" !!! ; fi

done; # <<< "$(cat ${transcriptpath}/${utterancename}.txt)"; 

echo ""; echo "while read line loop finished"; echo "";

countline=`cat $transcriptpath/$utterancename.txt | wc -l`; echo countline $countline;
#if [[ $countline != $linenum ]]; then echo "wc -l not equal to linenum"; fi



parallelnumber=2;
# Add ${utterancename}-ffmpeg-splitwav.sh to ffmepg-splitwav.sh list for serial or parallel execution
#echo "cat ${currentpath}/${tempfolder}/${utterancename}-ffmpeg-splitwav.sh | parallel -j $parallelnumber 2>&1 | tee -a ${currentpath}/${tempfolder}/${utterancename}-ffmpeg-splitwav-parallel.sh.log.txt" >> ${currentpath}/${tempfolder}/ffmepg-splitwav-parallel.sh

# Add ${utterancename}-ffmpeg-splitwav.sh to ffmepg-splitwav.sh list for serial execution
#echo "sh ${currentpath}/${tempfolder}/${utterancename}-ffmpeg-splitwav.sh 2>&1 | tee -a ${currentpath}/${tempfolder}/${utterancename}-ffmpeg-splitwav-serial.sh.log.txt" >> ${currentpath}/${tempfolder}/ffmepg-splitwav-serial.sh


 # from v1.1.1 remove the following ffmpeg-splitwav.sh execution within the script and suggest to run it by an external script calling
 # excute the -ffmpeg-splitwav.sh to devide the single line wav to /${cutfolder}/ folder
#sh ${currentpath}/${cutfolder}/${utterancename}-ffmpeg-splitwav.sh;
 # in v1.0.4 found that excuting ${utterancename}-ffmpeg-splitwav.sh will cause $1 $2 confusing


 echo ""
 echo "back to currentpath";
 cd $currentpath; pwd;
 echo "" 
 echo "ffmpeg processing for ${utterancename} ends!";
 echo ""
 