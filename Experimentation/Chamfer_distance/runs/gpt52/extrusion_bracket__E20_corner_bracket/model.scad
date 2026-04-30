$fn = 64;

module corner_bracket(envelope_x=28, envelope_y=28, envelope_z=20, wall=4, rib=3, hole_d=5.5, hole_off=10) {
    difference() {
        union() {
            // L-shaped body
            union() {
                cube([envelope_x, wall, envelope_z], center=false);
                cube([wall, envelope_y, envelope_z], center=false);
            }

            // Inner gusset/rib
            translate([wall, wall, 0])
                linear_extrude(height=envelope_z)
                    polygon(points=[[0,0],[envelope_x-wall,0],[0,envelope_y-wall]]);
        }

        // Mounting holes (two on each leg)
        for (zpos = [envelope_z*0.35, envelope_z*0.75]) {
            // Holes through Y-leg (along Y)
            translate([hole_off, wall/2, zpos])
                rotate([90,0,0])
                    cylinder(h=wall+0.6, d=hole_d, center=true);

            // Holes through X-leg (along X)
            translate([wall/2, hole_off, zpos])
                rotate([0,90,0])
                    cylinder(h=wall+0.6, d=hole_d, center=true);
        }

        // Reduce bulk near outer corner (cosmetic chamfer-like cut)
        translate([envelope_x-8, envelope_y-8, -0.5])
            cylinder(h=envelope_z+1, r=10, center=false);
    }
}

translate([-14,-14,-10])
    corner_bracket();