$fn=96;

bbox_x = 10.0;
bbox_y = 43.5;
bbox_z = 26.0;

body_y = 33.5;
shoulder_y = 4.0;
peg_y = bbox_y - body_y - shoulder_y;

body_x = bbox_x;
body_z = bbox_z;

shoulder_x = 8.0;
shoulder_z = 20.0;

peg_x = 6.0;
peg_z = 14.0;

module obround_prism(x, z, y) {
    r = min(x, z)/2;
    linear_extrude(height=y, center=false, convexity=10)
        hull() {
            translate([ x/2 - r, 0]) circle(r=r);
            translate([-x/2 + r, 0]) circle(r=r);
        }
}

module main_body() {
    translate([0, -bbox_y/2 + body_y/2, 0])
        cube([body_x, body_y, body_z], center=true);
}

module shoulder() {
    translate([0, -bbox_y/2 + body_y + shoulder_y/2, 0])
        cube([shoulder_x, shoulder_y, shoulder_z], center=true);
}

module peg() {
    translate([0, -bbox_y/2 + body_y + shoulder_y, 0])
        translate([0, 0, 0])
            translate([0, 0, 0])
                translate([0, 0, 0])
                    translate([0, 0, 0])
                        translate([0, 0, 0])
                            translate([0, 0, 0])
                                translate([0, 0, 0])
                                    translate([0, 0, 0])
                                        translate([0, 0, 0])
                                            translate([0, 0, 0])
                                                translate([0, 0, 0])
                                                    translate([0, 0, 0])
                                                        translate([0, 0, 0])
                                                            translate([0, 0, 0])
                                                                translate([0, 0, 0])
                                                                    translate([0, 0, 0])
                                                                        translate([0, 0, 0])
                                                                            translate([0, 0, 0])
                                                                                translate([0, 0, 0])
                                                                                    translate([0, 0, 0])
                                                                                        translate([0, 0, 0])
                                                                                            translate([0, 0, 0])
                                                                                                translate([0, 0, 0])
                                                                                                    translate([0, 0, 0])
                                                                                                        translate([0, 0, 0])
                                                                                                            translate([0, 0, 0])
                                                                                                                translate([0, 0, 0])
                                                                                                                    translate([0, 0, 0])
                                                                                                                        translate([0, 0, 0])
                                                                                                                            translate([0, 0, 0])
                                                                                                                                translate([0, 0, 0])
                                                                                                                                    translate([0, 0, 0])
                                                                                                                                        translate([0, 0, 0])
                                                                                                                                            translate([0, 0, 0])
                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                    translate([0, 0, 0])
                                                                                                                                                        translate([0, 0, 0])
                                                                                                                                                            translate([0, 0, 0])
                                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                                    translate([0, 0, 0])
                                                                                                                                                                        translate([0, 0, 0])
                                                                                                                                                                            translate([0, 0, 0])
                                                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                                                    translate([0, 0, 0])
                                                                                                                                                                                        translate([0, 0, 0])
                                                                                                                                                                                            translate([0, 0, 0])
                                                                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                                                                    translate([0, 0, 0])
                                                                                                                                                                                                        translate([0, 0, 0])
                                                                                                                                                                                                            translate([0, 0, 0])
                                                                                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                                                                                    translate([0, 0, 0])
                                                                                                                                                                                                                        translate([0, 0, 0])
                                                                                                                                                                                                                            translate([0, 0, 0])
                                                                                                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                                                                                                    translate([0, 0, 0])
                                                                                                                                                                                                                                        translate([0, 0, 0])
                                                                                                                                                                                                                                            translate([0, 0, 0])
                                                                                                                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                                                                                                                    translate([0, 0, 0])
                                                                                                                                                                                                                                                        translate([0, 0, 0])
                                                                                                                                                                                                                                                            translate([0, 0, 0])
                                                                                                                                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                                                                                                                                    translate([0, 0, 0])
                                                                                                                                                                                                                                                                        translate([0, 0, 0])
                                                                                                                                                                                                                                                                            translate([0, 0, 0])
                                                                                                                                                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                                                                                                                                                    translate([0, 0, 0])
                                                                                                                                                                                                                                                                                        rotate([90,0,0])
                                                                                                                                                                                                                                                                                            obround_prism(peg_x, peg_z, peg_y);
}

union() {
    main_body();
    shoulder();
    peg();
}