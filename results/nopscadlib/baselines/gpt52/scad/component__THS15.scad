$fn=64;

module mounting_hole(d=4, h=20) {
    cylinder(d=d, h=h, center=true);
}

module standoff(od=10, id=4.2, h=12) {
    difference() {
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.5, center=true);
    }
}

module base_plate(size=[80, 50, 6], corner_r=6) {
    hull() {
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*(size[0]/2-corner_r), sy*(size[1]/2-corner_r), 0])
                cylinder(r=corner_r, h=size[2], center=true);
        }
    }
}

module rib(length=60, width=4, height=18) {
    translate([0, 0, height/2])
        cube([length, width, height], center=true);
}

module component() {
    difference() {
        union() {
            base_plate([80, 50, 6], 6);

            for (sx=[-1,1], sy=[-1,1]) {
                translate([sx*30, sy*17, 6/2 + 12/2])
                    standoff(od=10, id=4.2, h=12);
            }

            translate([0, 0, 6/2])
                rib(length=70, width=4, height=18);

            rotate([0,0,90])
                translate([0, 0, 6/2])
                    rib(length=40, width=4, height=14);

            translate([0, 0, 6/2 + 18])
                cylinder(d=18, h=10, center=true);
        }

        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*30, sy*17, 0])
                mounting_hole(d=4.2, h=60);
        }

        translate([0, 0, 0])
            cylinder(d=10, h=60, center=true);

        translate([0, 0, 6/2 + 18])
            cylinder(d=8, h=30, center=true);
    }
}

component();