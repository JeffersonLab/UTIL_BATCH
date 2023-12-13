#! /bin/bash

### Nathan Heinrich, University of Regina
### 
echo "Running as ${USER}"
RunList=$1
if [[ -z "$1" ]]; then
    echo "I need a run list process!"
    echo "Please provide a run list as input"
    exit 2
fi

if [[ $2 -eq "" ]]; then
    MAXEVENTS=-1
else
    MAXEVENTS=$2
fi

# Set path depending upon hostname. Change or add more as needed  
if [[ "${HOSTNAME}" = *"farm"* ]]; then  
    REPLAYPATH="/group/c-pionlt/USERS/${USER}/hallc_replay_lt"
    #REPLAYPATH="/group/c-pionlt/online_analysis/hallc_replay_lt"
    if [[ "${HOSTNAME}" != *"ifarm"* ]]; then
	#source /site/12gev_phys/softenv.sh 2.4
	source /apps/root/6.18.04/setroot_CUE.bash
    fi
    cd "$REPLAYPATH"
    source "$REPLAYPATH/setup.sh"
elif [[ "${HOSTNAME}" = *"qcd"* ]]; then
    REPLAYPATH="/group/c-pionlt/USERS/${USER}/hallc_replay_lt"
    #source /site/12gev_phys/softenv.sh 2.4
    source /apps/root/6.18.04/setroot_CUE.bash
    cd "$REPLAYPATH"
    source "$REPLAYPATH/setup.sh" 
elif [[ "${HOSTNAME}" = *"cdaq"* ]]; then
    REPLAYPATH="/home/cdaq/hallc-online/hallc_replay_lt"
elif [[ "${HOSTNAME}" = *"phys.uregina.ca"* ]]; then
    REPLAYPATH="/home/${USER}/work/JLab/hallc_replay_lt"
fi
cd $REPLAYPATH

# Input run numbers, this just points to a file which is a list of run numbers, one number per line
inputFile="/group/c-pionlt/USERS/${USER}/hallc_replay_lt/UTIL_BATCH/InputRunLists/${RunList}"

if [ ! -r $inputFile ]
then
    echo "Could Not Access ${inputFile}!!!!"
    echo "Check that file exists!!!"
    exit 1
fi

echo "Running hadd command for runlist: ${inputFile}"
RUNNUMLIST=""
FILELIST=""
COUNTER=0
LAST=""
FIRST=""
line=""

while IFS='' read -r line || [[ -n "$line" ]]; do
      #echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"          
      echo "Run number read from file: $line"
      echo ""
      if [ $COUNTER -eq 0 ]
      then
	  FIRST="${line}"
      fi
      RUNNUMLIST+="${line} "
      FILELIST+="Pion_coin_replay_calibration_${line}_${MAXEVENTS}.root "
      LAST="${line}"
      COUNTER+=1
done < "$inputFile"

cd "ROOTfiles/Calib/CER"

if [ -e "Combined_${FIRST}-${LAST}.root" ]
then
    rm "Combined_${FIRST}-${LAST}.root"
fi

echo "Runlist is: ${RUNNUMLIST}"
echo ""
echo "Running Command: "
echo "hadd Combined_${FIRST}-${LAST}.root ${FILELIST}"
eval "hadd Combined_${FIRST}-${LAST}.root ${FILELIST}"

exit 0
