#!/bin/bash

echo "Starting Replay script"
echo "I take as arguments the Run Number and max number of events!"
RUNNUMBER=$1
MAXEVENTS=-1
### Check you've provided the an argument
if [[ $1 -eq "" ]]; then
    echo "I need a Run Number!"
    echo "Please provide a run number as input"
    exit 2
fi
if [[ ${USER} = "cdaq" ]]; then
    echo "Warning, running as cdaq."
    echo "Please be sure you want to do this."
    echo "Comment this section out and run again if you're sure."
    exit 2
fi          

# Set path depending upon hostname. Change or add more as needed  
if [[ "${HOSTNAME}" = *"farm"* ]]; then  
    REPLAYPATH="/group/c-pionlt/online_analysis/hallc_replay_lt"
    if [[ "${HOSTNAME}" != *"ifarm"* ]]; then
	source /site/12gev_phys/softenv.sh 2.4
	source /apps/root/6.18.04/setroot_CUE.bash
    fi
    cd "$REPLAYPATH"
    source "$REPLAYPATH/setup.sh"
elif [[ "${HOSTNAME}" = *"qcd"* ]]; then
    REPLAYPATH="/group/c-pionlt/USERS/${USER}/hallc_replay_lt"
    source /site/12gev_phys/softenv.sh 2.4
    source /apps/root/6.18.04/setroot_CUE.bash
    cd "$REPLAYPATH"
    source "$REPLAYPATH/setup.sh" 
elif [[ "${HOSTNAME}" = *"cdaq"* ]]; then
    REPLAYPATH="/home/cdaq/hallc-online/hallc_replay_lt"
elif [[ "${HOSTNAME}" = *"phys.uregina.ca"* ]]; then
    REPLAYPATH="/home/${USER}/work/JLab/hallc_replay_lt"
fi
UTILPATH="${REPLAYPATH}/UTIL_PION"
cd $REPLAYPATH

# Create and use BCM calib for file if it doesn't exist
if [ ! -f "$REPLAYPATH/ROOTfiles/Scalers/coin_replay_scalers_${RUNNUMBER}_-1.root" ]; then
    eval "$REPLAYPATH/hcana -l -q \"SCRIPTS/COIN/SCALERS/replay_coin_scalers.C($RUNNUMBER,-1)\""
    cd "$REPLAYPATH/CALIBRATION/bcm_current_map"
    root -b<<EOF 
.L ScalerCalib.C+
.x run.C("${REPLAYPATH}/ROOTfiles/Scalers/coin_replay_scalers_${RUNNUMBER}_-1.root")
.q  
EOF
    mv bcmcurrent_$RUNNUMBER.param $REPLAYPATH/PARAM/HMS/BCM/CALIB/bcmcurrent_$RUNNUMBER.param
    cd $REPLAYPATH
else echo "Scaler replayfile already found for this run in $REPLAYPATH/ROOTfiles/ - Skipping scaler replay step"
fi

# Run 50k replay for all events in file
#if [ ! -f "$REPLAYPATH/ROOTfiles/Analysis/Lumi/coin_replay_Full_Lumi_${RUNNUMBER}_100000.root" ]; then
#    if [[ "${HOSTNAME}" != *"ifarm"* ]]; then
#	eval "$REPLAYPATH/hcana -l -q \"SCRIPTS/COIN/PRODUCTION/FullReplay_coin_Lumi.C($RUNNUMBER,100000)\"" 
#    elif [[ "${HOSTNAME}" == *"ifarm"* ]]; then
#	eval "$REPLAYPATH/hcana -l -q \"SCRIPTS/COIN/PRODUCTION/FullReplay_coin_Lumi.C($RUNNUMBER,100000)\""
#    fi
#else echo "100k replayfile already found for this run in $REPLAYPATH/ROOTfiles/Analysis/Lumi - Skipping replay step"
#fi

# Run full replay for all events in file
if [ ! -f "$REPLAYPATH/ROOTfiles/Analysis/Lumi/coin_replay_Full_Lumi_${RUNNUMBER}_${MAXEVENTS}.root" ]; then
    if [[ "${HOSTNAME}" != *"ifarm"* ]]; then
	eval "$REPLAYPATH/hcana -l -q \"SCRIPTS/COIN/PRODUCTION/FullReplay_coin_Lumi2.C($RUNNUMBER,$MAXEVENTS)\"" 
    elif [[ "${HOSTNAME}" == *"ifarm"* ]]; then
	eval "$REPLAYPATH/hcana -l -q \"SCRIPTS/COIN/PRODUCTION/FullReplay_coin_Lumi2.C($RUNNUMBER,$MAXEVENTS)\""
    fi
else echo "All events replayfile already found for this run in $REPLAYPATH/ROOTfiles/Analysis/Lumi - Skipping replay step"
fi

exit 0