$fn=96;

L = 24.5;
W = 7.8;
H = 4.5;

slot_L = 16.8;
slot_W = 3.6;

tip_L = 5.2;

notch_L = 6.2;
notch_depth = 0.9;
notch_H = 2.2;

facet_cut = 1.0;

module obround2d(len, wid){
    r = wid/2;
    hull(){
        translate([-(len/2 - r),0]) circle(r=r);
        translate([ (len/2 - r),0]) circle(r=r);
    }
}

module outer_body(){
    union(){
        translate([0,0,0])
            linear_extrude(height=H, center=true)
                obround2d(L, W);

        translate([ L/2 - tip_L/2, 0, 0])
            scale([1, W/(2*tip_L), H/(2*tip_L)])
                rotate([0,90,0]) cylinder(h=tip_L, r1=tip_L, r2=0, center=true);

        translate([-L/2 + tip_L/2, 0, 0])
            scale([1, W/(2*tip_L), H/(2*tip_L)])
                rotate([0,90,0]) cylinder(h=tip_L, r1=0, r2=tip_L, center=true);
    }
}

module faceting(){
    union(){
        translate([0,0,0])
            rotate([0,45,0])
                cube([L+6, W+6, H+6], center=true);

        translate([0,0,0])
            rotate([0,-45,0])
                cube([L+6, W+6, H+6], center=true);

        translate([0,0,0])
            rotate([45,0,0])
                cube([L+6, W+6, H+6], center=true);

        translate([0,0,0])
            rotate([-45,0,0])
                cube([L+6, W+6, H+6], center=true);
    }
}

module side_notches(){
    union(){
        translate([0,  W/2 - notch_depth/2, 0])
            cube([notch_L, notch_depth, notch_H], center=true);
        translate([0, -W/2 + notch_depth/2, 0])
            cube([notch_L, notch_depth, notch_H], center=true);
    }
}

module slot_cut(){
    linear_extrude(height=H+1, center=true)
        obround2d(slot_L, slot_W);
}

difference(){
    intersection(){
        outer_body();
        difference(){
            translate([0,0,0]) cube([L+2, W+2, H+2], center=true);
            translate([0,0,0]) faceting();
        }
    }
    slot_cut();
    side_notches();
}