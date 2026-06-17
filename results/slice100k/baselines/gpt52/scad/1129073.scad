$fn=96;

L = 24.5;
W = 7.8;
T = 4.5;

slot_L = 16.8;
slot_W = 3.6;

notch_L = 3.2;
notch_H = 1.2;
notch_D = 0.9;

module spindle_outer(len=L, wid=W, th=T) {
    hull() {
        translate([0,0,0]) cube([len*0.62, wid, th], center=true);
        translate([ len/2 - 0.35, 0, 0]) cube([0.7, wid*0.22, th*0.55], center=true);
        translate([-len/2 + 0.35, 0, 0]) cube([0.7, wid*0.22, th*0.55], center=true);
    }
}

module chamfered_body(len=L, wid=W, th=T) {
    intersection() {
        spindle_outer(len,wid,th);
        hull() {
            translate([0,0,0]) cube([len*0.70, wid*0.92, th*0.92], center=true);
            translate([ len/2 - 0.55, 0, 0]) cube([1.1, wid*0.30, th*0.55], center=true);
            translate([-len/2 + 0.55, 0, 0]) cube([1.1, wid*0.30, th*0.55], center=true);
        }
    }
}

module rounded_slot(len=slot_L, wid=slot_W, th=T+0.6) {
    hull() {
        translate([ len/2 - wid/2, 0, 0]) cylinder(h=th, r=wid/2, center=true);
        translate([-len/2 + wid/2, 0, 0]) cylinder(h=th, r=wid/2, center=true);
    }
}

module side_notches() {
    for (sx=[-1,1]) {
        translate([0, sx*(W/2 - notch_D/2 + 0.01), 0])
            cube([notch_L, notch_D, notch_H], center=true);
    }
}

difference() {
    chamfered_body(L,W,T);
    rounded_slot(slot_L, slot_W, T+0.8);
    side_notches();
}