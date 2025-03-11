/////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Audiokinetic Wwise generated include file. Do not edit.
//
/////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef __WWISE_IDS_H__
#define __WWISE_IDS_H__

#include <AK/SoundEngine/Common/AkTypes.h>

namespace AK
{
    namespace EVENTS
    {
        static const AkUniqueID HIT = 1116398592U;
        static const AkUniqueID PAUSE_ADAPTIVE_MUSIC = 2940364306U;
        static const AkUniqueID PLAY_MUSIC = 2932040671U;
        static const AkUniqueID RESUME_ADAPTIVE_MUSIC = 458359289U;
        static const AkUniqueID STOP_ADAPTIVE_MUSIC = 2452122506U;
    } // namespace EVENTS

    namespace STATES
    {
        namespace BOSSSTATE
        {
            static const AkUniqueID GROUP = 3011728793U;

            namespace STATE
            {
                static const AkUniqueID DEFEATED = 2791675679U;
                static const AkUniqueID NONE = 748895195U;
            } // namespace STATE
        } // namespace BOSSSTATE

        namespace ENEMYTYPES
        {
            static const AkUniqueID GROUP = 520339718U;

            namespace STATE
            {
                static const AkUniqueID ELITEENEMY = 2906824402U;
                static const AkUniqueID NOENEMY = 132730248U;
                static const AkUniqueID NONE = 748895195U;
            } // namespace STATE
        } // namespace ENEMYTYPES

        namespace MUSICSTATE
        {
            static const AkUniqueID GROUP = 1021618141U;

            namespace STATE
            {
                static const AkUniqueID BOSS = 1560169506U;
                static const AkUniqueID COMBAT = 2764240573U;
                static const AkUniqueID MENU = 2607556080U;
                static const AkUniqueID NONE = 748895195U;
            } // namespace STATE
        } // namespace MUSICSTATE

        namespace PLAYERLIFE
        {
            static const AkUniqueID GROUP = 444815956U;

            namespace STATE
            {
                static const AkUniqueID ALIVE = 655265632U;
                static const AkUniqueID DEFEATED = 2791675679U;
                static const AkUniqueID NONE = 748895195U;
            } // namespace STATE
        } // namespace PLAYERLIFE

    } // namespace STATES

    namespace GAME_PARAMETERS
    {
        static const AkUniqueID BOSSHEALTH = 131068444U;
        static const AkUniqueID KILLCOUNT = 790457970U;
        static const AkUniqueID MUSICVOLUME = 2346531308U;
        static const AkUniqueID PLAYERHEALTH = 151362964U;
        static const AkUniqueID SS_AIR_FEAR = 1351367891U;
        static const AkUniqueID SS_AIR_FREEFALL = 3002758120U;
        static const AkUniqueID SS_AIR_FURY = 1029930033U;
        static const AkUniqueID SS_AIR_MONTH = 2648548617U;
        static const AkUniqueID SS_AIR_PRESENCE = 3847924954U;
        static const AkUniqueID SS_AIR_RPM = 822163944U;
        static const AkUniqueID SS_AIR_SIZE = 3074696722U;
        static const AkUniqueID SS_AIR_STORM = 3715662592U;
        static const AkUniqueID SS_AIR_TIMEOFDAY = 3203397129U;
        static const AkUniqueID SS_AIR_TURBULENCE = 4160247818U;
        static const AkUniqueID VERSEKICK = 2752475886U;
    } // namespace GAME_PARAMETERS

    namespace TRIGGERS
    {
        static const AkUniqueID CYMBALSWELL = 2765540238U;
    } // namespace TRIGGERS

    namespace BANKS
    {
        static const AkUniqueID INIT = 1355168291U;
        static const AkUniqueID MAIN = 3161908922U;
    } // namespace BANKS

    namespace BUSSES
    {
        static const AkUniqueID MASTER_AUDIO_BUS = 3803692087U;
    } // namespace BUSSES

    namespace AUX_BUSSES
    {
        static const AkUniqueID DELAY = 357718954U;
        static const AkUniqueID REVERB = 348963605U;
    } // namespace AUX_BUSSES

    namespace AUDIO_DEVICES
    {
        static const AkUniqueID NO_OUTPUT = 2317455096U;
        static const AkUniqueID SYSTEM = 3859886410U;
    } // namespace AUDIO_DEVICES

}// namespace AK

#endif // __WWISE_IDS_H__
