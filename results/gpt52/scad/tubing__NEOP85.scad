$fn=96;

module neoprene_tubing(outer_d=20, inner_d=14, length=120, bend_radius=60, bend_angle=120) {
    union() {
        // Straight section centered at origin along X
        difference() {
            translate([-length/2, 0, 0])
                rotate([0,90,0])
                    cylinder(h=length, d=outer_d, center=false);
            translate([-length/2, 0, 0])
                rotate([0,90,0])
                    cylinder(h=length, d=inner_d, center=false);
        }

        // Bent section (torus segment) attached to +X end
        translate([length/2, 0, 0])
            rotate([0,0,0])
                difference() {
                    rotate_extrude(angle=bend_angle, convexity=10)
                        translate([bend_radius, 0, 0])
                            circle(d=outer_d);
                    rotate_extrude(angle=bend_angle, convexity=10)
                        translate([bend_radius, 0, 0])
                            circle(d=inner_d);
                }
    }
}

neoprene_tubing(outer_d=20, inner_d=14, length=120, bend_radius=60, bend_angle=120);