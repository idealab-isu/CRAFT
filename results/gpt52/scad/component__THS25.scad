$fn=64;

module mounting_hole(d=4, h=20) {
    cylinder(d=d, h=h, center=true);
}

module counterbore(d=8, h=3, z=0) {
    translate([0,0,z]) cylinder(d=d, h=h, center=true);
}

module base_plate(size=[60,40,6]) {
    cube(size, center=true);
}

module standoff(d=10, h=12, hole_d=4) {
    difference() {
        cylinder(d=d, h=h, center=true);
        cylinder(d=hole_d, h=h+2, center=true);
    }
}

module rib(len=30, thick=4, height=12) {
    translate([0,0,-height/2])
        linear_extrude(height=height)
            polygon(points=[
                [-len/2, 0],
                [ len/2, 0],
                [ len/2-6, thick],
                [-len/2+6, thick]
            ]);
}

module component() {
    plate=[60,40,6];
    st_h=12;
    st_d=10;
    hole_d=4;
    cb_d=8;
    cb_h=3;

    hole_x=22;
    hole_y=12;

    difference() {
        union() {
            base_plate(plate);

            translate([ hole_x,  hole_y, (plate[2]/2)+(st_h/2)]) standoff(d=st_d, h=st_h, hole_d=hole_d);
            translate([-hole_x,  hole_y, (plate[2]/2)+(st_h/2)]) standoff(d=st_d, h=st_h, hole_d=hole_d);
            translate([ hole_x, -hole_y, (plate[2]/2)+(st_h/2)]) standoff(d=st_d, h=st_h, hole_d=hole_d);
            translate([-hole_x, -hole_y, (plate[2]/2)+(st_h/2)]) standoff(d=st_d, h=st_h, hole_d=hole_d);

            translate([0,0,plate[2]/2]) rib(len=44, thick=4, height=12);
            rotate([0,0,90]) translate([0,0,plate[2]/2]) rib(len=28, thick=4, height=12);
        }

        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*hole_x, sy*hole_y, 0]) mounting_hole(d=hole_d, h=plate[2]+st_h+10);
            translate([sx*hole_x, sy*hole_y, (plate[2]/2)+(st_h)-cb_h/2]) counterbore(d=cb_d, h=cb_h, z=0);
        }

        translate([0,0,0]) cylinder(d=18, h=plate[2]+2, center=true);
        translate([0,0,plate[2]/2+6]) rotate([90,0,0]) cylinder(d=8, h=plate[1]+2, center=true);
    }
}

component();