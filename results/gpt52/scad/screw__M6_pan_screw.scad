$fn=96;

d_shank = 6.0;
l_shank = 10.0;

d_head = 12.0;
h_head = 4.75;

r_fillet = 0.8;
h_dome = 1.2;

module pan_head(d=12, h=4.75, dome=1.2, fillet=0.8) {
    base_h = max(0.01, h - dome);
    union() {
        cylinder(d=d, h=base_h);
        translate([0,0,base_h])
            intersection() {
                sphere(d=d);
                cylinder(d=d, h=dome);
            }
        if (fillet > 0) {
            translate([0,0,0])
                difference() {
                    cylinder(d=d, h=fillet);
                    translate([0,0,fillet])
                        rotate_extrude()
                            translate([d/2 - fillet, 0, 0])
                                circle(r=fillet, $fn=64);
                }
        }
    }
}

module screw() {
    union() {
        translate([0,0,-l_shank])
            cylinder(d=d_shank, h=l_shank);
        pan_head(d=d_head, h=h_head, dome=h_dome, fillet=r_fillet);
    }
}

screw();