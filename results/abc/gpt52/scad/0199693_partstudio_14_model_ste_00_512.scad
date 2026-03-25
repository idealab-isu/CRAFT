$fn=96;

L = 180;
W = 40;
T = 8;

plate_r = 32;
plate_t = 8;
plate_h = 70;

hole_r = 18;

small_hole_r = 4;
small_hole_offset_r = 22;

slot_w = 12;
slot_h = 18;
slot_len = 52;

diamond_w = 18;
diamond_h = 18;

module end_plate() {
    difference() {
        cylinder(h=plate_h, r=plate_r, center=false);
        translate([0,0,plate_h/2]) cylinder(h=plate_h+2, r=hole_r, center=true);
        for (a=[0:90:270]) {
            translate([small_hole_offset_r*cos(a), small_hole_offset_r*sin(a), plate_h/2])
                cylinder(h=plate_h+2, r=small_hole_r, center=true);
        }
        for (a=[45,135,225,315]) {
            translate([18*cos(a), 18*sin(a), plate_h/2])
                rotate([0,0,a])
                    cube([10,6,plate_h+2], center=true);
        }
    }
}

module hex_slot(len=40, w=12, h=18, zc=0) {
    translate([0,0,zc])
        linear_extrude(height=T+2, center=true)
            polygon(points=[
                [-len/2 + w/2, -h/2],
                [ len/2 - w/2, -h/2],
                [ len/2, 0],
                [ len/2 - w/2,  h/2],
                [-len/2 + w/2,  h/2],
                [-len/2, 0]
            ]);
}

module diamond_window(w=18, h=18, zc=0) {
    translate([0,0,zc])
        linear_extrude(height=T+2, center=true)
            polygon(points=[
                [0, h/2],
                [w/2, 0],
                [0, -h/2],
                [-w/2, 0]
            ]);
}

module crossbar() {
    difference() {
        translate([0,0,0]) cube([L, W, T], center=true);

        translate([-L*0.25, 0, 0]) hex_slot(len=slot_len, w=slot_w, h=slot_h, zc=0);
        translate([ L*0.25, 0, 0]) hex_slot(len=slot_len, w=slot_w, h=slot_h, zc=0);

        translate([0,0,0]) diamond_window(w=diamond_w, h=diamond_h, zc=0);

        for (sx=[-1,1]) {
            translate([sx*L*0.18, 0, 0])
                linear_extrude(height=T+2, center=true)
                    offset(r=1.2)
                        square([18,8], center=true);
        }
    }
}

module bracket() {
    union() {
        crossbar();

        translate([-L/2 + plate_t/2, 0, T/2])
            rotate([0,90,0])
                end_plate();

        translate([ L/2 - plate_t/2, 0, T/2])
            rotate([0,90,0])
                end_plate();
    }
}

bracket();