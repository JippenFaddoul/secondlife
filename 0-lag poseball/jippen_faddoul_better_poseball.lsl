// Source can be found at: https://github.com/JippenFaddoul/secondlife
// Copyright (c) 2007, Jippen Faddoul
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

//This text will appear in the floating title above the ball
string TITLE="Sit here";            
//You can play with these numbers to adjust how far the person sits from the ball. ( <X,Y,Z> )
vector offset=<0.0,0.0,0.5>;            

///////////////////// LEAVE THIS ALONE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
string ANIMATION;
integer visible = TRUE;
key avatar;

vector COLOR = <1.0,1.0,1.0>;
float ALPHA_ON = 1.0;
float ALPHA_OFF = 0.0;

show(){
    visible = TRUE;
    llSetText(TITLE, COLOR,ALPHA_ON);        
    llSetAlpha(ALPHA_ON, ALL_SIDES);
}

hide(){
    visible = FALSE;
    llSetText("", COLOR,ALPHA_ON);        
    llSetAlpha(ALPHA_OFF, ALL_SIDES);
}

default{
    state_entry() {
        TITLE = llGetObjectName();
        llSitTarget(offset,ZERO_ROTATION);
        if((ANIMATION = llGetInventoryName(INVENTORY_ANIMATION,0)) == ""){
            llOwnerSay("Error: No animation");
            ANIMATION = "sit";
            }
        llSetSitText(TITLE);
        show();
    }

    touch_start(integer detected) {
        //llOwnerSay("Memory: " + (string)llGetFreeMemory());
        if(visible){ hide(); }
        else       { show(); }
    }
    
    changed(integer change) {
        if(change & CHANGED_LINK) {
            avatar = llAvatarOnSitTarget();
            if(avatar != NULL_KEY){
                //SOMEONE SAT DOWN
                hide();
                llRequestPermissions(avatar,PERMISSION_TRIGGER_ANIMATION);
                return;
            }else{
                //SOMEONE STOOD UP
                if (llGetPermissionsKey() != NULL_KEY){ llStopAnimation(ANIMATION); }
                show();
                return;
            }
        }
        if(change & CHANGED_INVENTORY) { llResetScript(); }
        if(change & CHANGED_OWNER)     { llResetScript(); }
    }
    
    run_time_permissions(integer perm) {
        if(perm & PERMISSION_TRIGGER_ANIMATION) {
            llStopAnimation("sit");
            llStartAnimation(ANIMATION);
            hide();
        }
    }
}
