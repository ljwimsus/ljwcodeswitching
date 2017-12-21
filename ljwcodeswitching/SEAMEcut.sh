filename=NI01MAX_0101; 

scriptname=$0; echo scriptname $0;

: ' ffmpeg -i ${filename}.flac ${filename}.wav; ';

 linenum=1;

echo "" > ${scriptname}-ffmpeg.sh;

cat ${filename}.txt | while read line ; do echo; echo line#${linenum} ${line};

singleline=${line/${filename}/}; echo singleline ${singleline};

singlelinetext=${singleline//[0-9]/}; echo singlelinetext ${singlelinetext};
 singlelinetimecut1=${singleline%[0-9]*}; echo singlelinetimecut1 ${singlelinetimecut1};
 singlelinetimeminus1=${#singlelinetimecut1}; echo singlelinetimeminus1 ${singlelinetimeminus1};
 singlelinetimeplus1=`expr ${singlelinetimeminus1} + 1`; echo singlelinetimeplus1 ${singlelinetimeplus1};
singlelinetime=${singleline:0:${singlelinetimeplus1}}; echo singlelinetime ${singlelinetime};

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
 

: ' echo "ffmpeg -i ${filename}.wav -ss ${starttimeposition} -to ${endtimeposition} -c copy ./cut/${filename}.${starttimeposition}-${endtimeposition}.wav; " >> ffmpeg.sh; ';
echo "ffmpeg -i ${filename}.wav -ss ${starttimeposition} -to ${endtimeposition} -c copy ./cut/${filename}.${linenum}.wav; " >> ${scriptname}-ffmpeg.sh;


 linenum=`expr ${linenum} + 1`;

done;

 sh ${scriptname}-ffmpeg.sh


 unset line;
 unset singleline;
 unset singlelinetext;
 unset singlelinetime;
 unset singlelinetimecut1;
 unset singlelinetimeminus1;
 unset singlelinetimeplus1;
 unset starttime;
 unset starttimelength;
 unset starttimesec;
 unset starttimemillisec;
 unset starttimeposition;
 unset endtime;
 unset endtimelength;
 unset endtimesec;
 unset endtimemillisec;
 unset endtimeposition;

 unset linenum;
 unset scriptname;
 unset filename;