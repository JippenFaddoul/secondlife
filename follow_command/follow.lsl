// Source can be found at: https://github.com/JippenFaddoul/secondlife
// Copyright (c) 2016, Jippen Faddoul
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without 
// modification, are permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation 
//    and/or other materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors
//    may be used to endorse or promote products derived from this software 
//    without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
// POSSIBILITY OF SUCH DAMAGE.

integer RLV_ENABLED = FALSE;
key TARGET = NULL_KEY;
string STARTSWITH;
integer STARTSWITH_LEN;

// RLV-Force avatar to face the leasher by Tapple Gao
turnToTarget(vector target){
    if(!RLV_ENABLED) {return; } 
    vector pointTo = target - llGetPos();
    vector myEuler = llRot2Euler(llGetRot());
    float  myAngle = PI_BY_TWO - myEuler.z;
    float  turnAngle = llAtan2(pointTo.x, pointTo.y) - myAngle;
    while (turnAngle < -PI) turnAngle += TWO_PI;
    while (turnAngle >  PI) turnAngle -= TWO_PI;
    if (turnAngle < -1.221730) turnAngle = -1.221730;
    if (turnAngle >  1.221730) turnAngle =  1.221730;
    llOwnerSay("@setrot:" + (string)(myAngle+turnAngle) + "=force");
}

YankTo(key kIn){
    llMoveToTarget(llList2Vector(llGetObjectDetails(kIn, [OBJECT_POS]), 0), 0.5);
    llSleep(1.0);
    llStopMoveToTarget();    
}

integer findUser(integer d){
    if(llToLower(llGetSubString(llDetectedName(d), 0, STARTSWITH_LEN - 1)) == STARTSWITH){
        return TRUE;
    }
    if(llToLower(llGetSubString(llGetDisplayName(llDetectedKey(d)), 0, STARTSWITH_LEN - 1)) == STARTSWITH){
        return TRUE;
    }
    return FALSE;
}


cleanup(){
    STARTSWITH = "";
    STARTSWITH_LEN = 0;
    TARGET = NULL_KEY; 
    llSensorRepeat("", "", 0, 0, 0, 0);   
}

default{
    state_entry(){
        llListen(0, "", llGetOwner(), "");
        llListen(53452455, "", llGetOwner(), "");
        llOwnerSay("@version=53452455");
        llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS);
        llOwnerSay("Type /follow <name> to start following them around. Press an arrow key to stop following.");
    }
    
    listen(integer channel, string speaker, key avatar, string msg){
        if(channel == 53452455){ 
            RLV_ENABLED = TRUE; 
            llListenRemove(2);
        }
        msg = llToLower(llStringTrim(msg, STRING_TRIM));
        if(msg == "/unfollow"){
            cleanup();
            return;
        }
        if(llGetSubString(msg, 0, 6) != "/follow"){ return; }
        STARTSWITH = llStringTrim(llGetSubString(msg, 7, -1), STRING_TRIM);
        STARTSWITH_LEN = llStringLength(STARTSWITH);
        if(STARTSWITH_LEN){
            llSensor("", "", AGENT, 96.0, PI );
        } else {
            cleanup();
        }
    }

    on_rez(integer param){ llResetScript(); }
    
    sensor(integer detected){
        vector v;
        if(TARGET == NULL_KEY){
            llOwnerSay("s");
            integer counter = 0;
            while(detected--){
                if(findUser(detected)){
                    TARGET = llDetectedKey(detected);
                    v = llDetectedPos(detected);
                    counter++;
                }
            }
            if(counter == 0){
                llOwnerSay("Can't find anyone who's name starts with: " + STARTSWITH );
                cleanup();    
            } else if(counter > 1){
                cleanup();
                llOwnerSay("Found more than one matching avatar. Please type a more exact name.");
                cleanup();
                return;
            } else {
                llOwnerSay("Now following " + llGetDisplayName(TARGET) + " (" + llKey2Name(TARGET) + ")");
                llSensorRepeat("", TARGET, AGENT, 96, PI, 0.5);
                llTakeControls(0x33f, TRUE, TRUE);
            }
        }
        if(TARGET == NULL_KEY){ return; }
        // Start following
        turnToTarget(v);
        if(v == ZERO_VECTOR){ v = llDetectedPos(0); }
        if(llVecDist(v, llGetPos()) >= 6.0){
            llMoveToTarget(v, 2.0);    
        }
    }
    
    no_sensor(){
        llOwnerSay("Can't find anyone who's name starts with: " + STARTSWITH );
        cleanup();
    }
    
    control(key id, integer level, integer edge){
        llOwnerSay("No longer following");
        llReleaseControls();
        cleanup();    
    }

}
