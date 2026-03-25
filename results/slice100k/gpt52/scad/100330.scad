$fn=96;

L = 61.2;
W = 31.9;
T = 5.5;

tab_r = W/2;                 // 15.95
tab_center_offset = L/2 - tab_r; // 14.65

web_w = 16.0;
web_len = 30.0;
web_offset_x = 4.0;

hole_size = 4.2;
hole_depth = T + 0.4;
hole_tip_inset = 6.0;
hole_y = tab_center_offset + tab_r - hole_tip_inset;

recess_depth = 1.2;
recess_w = 12.0;
recess_h = 8.0;
recess_y_offset = 2.0;

module capsule2d(len, r){
    hull(){
        translate([0, -len/2 + r]) circle(r=r);
        translate([0,  len/2 - r]) circle(r=r);
    }
}

module tab2d(){
    capsule2d(2*tab_r, tab_r);
}

module web2d(){
    translate([web_offset_x, 0]) square([web_w, web_len], center=true);
}

module plate2d(){
    union(){
        translate([0,  tab_center_offset]) tab2d();
        translate([0, -tab_center_offset]) tab2d();
        web2d();
    }
}

module recess_cut(){
    union(){
        translate([web_offset_x,  tab_center_offset - tab_r + recess_y_offset, T - recess_depth/2])
            cube([recess_w, recess_h, recess_depth], center=true);
        translate([web_offset_x, -tab_center_offset + tab_r - recess_y_offset, T - recess_depth/2])
            cube([recess_w, recess_h, recess_depth], center=true);
    }
}

module holes_cut(){
    union(){
        translate([0,  hole_y, T/2]) cube([hole_size, hole_size, hole_depth], center=true);
        translate([0, -hole_y, T/2]) cube([hole_size, hole_size, hole_depth], center=true);
    }
}

difference(){
    linear_extrude(height=T, center=true) plate2d();
    holes_cut();
    recess_cut();
}