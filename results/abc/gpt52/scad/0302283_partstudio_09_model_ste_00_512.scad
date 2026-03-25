$fn=64;

bbox_x = 0.3;
bbox_y = 0.1;
bbox_z = 0.1;

t = 0.01;

plate_len = 0.28;
plate_h   = 0.09;

flange_len = 0.08;
flange_w   = 0.09;

bend_r = 0.015;

hole_d = 0.012;
hole_edge_x = 0.03;
hole_edge_z = 0.02;

slot_w = 0.02;
slot_l = 0.03;
slot_offset_from_bend = 0.012;

gap_between = 0.02;

module rounded_L_bracket() {
    difference() {
        union() {
            translate([-plate_len/2, 0, 0])
                cube([plate_len, t, plate_h], center=false);

            translate([-flange_len/2, 0, 0])
                cube([flange_len, flange_w, t], center=false);

            translate([0, 0, 0])
                rotate([90,0,0])
                    cylinder(r=bend_r, h=t, center=false);

            translate([0, 0, 0])
                rotate([0,90,0])
                    cylinder(r=bend_r, h=t, center=false);
        }

        for (ix = [-1, 1])
            for (iz = [-1, 1]) {
                xh = ix * (plate_len/2 - hole_edge_x);
                zh = (plate_h/2) + iz * (plate_h/2 - hole_edge_z);
                translate([xh, t/2, zh])
                    rotate([90,0,0])
                        cylinder(d=hole_d, h=t*3, center=true);
            }

        translate([0, slot_offset_from_bend + slot_l/2, t/2])
            cube([slot_w, slot_l, t*3], center=true);
    }
}

module bracket_pair() {
    union() {
        translate([0, -gap_between/2 - flange_w/2, -plate_h/2])
            rounded_L_bracket();

        translate([0,  gap_between/2 + flange_w/2, -plate_h/2])
            mirror([0,1,0])
                rounded_L_bracket();
    }
}

scale([bbox_x/0.3, bbox_y/0.1, bbox_z/0.1])
    bracket_pair();