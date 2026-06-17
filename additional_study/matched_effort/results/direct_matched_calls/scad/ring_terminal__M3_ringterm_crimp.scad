$fn=128;

// Ring terminal parameters (mm)
ring_outer_d = 18;
ring_inner_d = 8;
ring_thickness = 2.2;

neck_length = 10;
neck_width  = 7;
neck_thickness = ring_thickness;

barrel_length = 18;
barrel_outer_d = 7.5;
barrel_inner_d = 4.2;

flare_length = 4;          // transition from neck to barrel
flare_width  = 9;          // width at ring side of flare

edge_round = 0.8;          // visual softening (approx)

// Helpers
module rounded_prism(size=[10,10,2], r=0.8) {
    // Minkowski rounding (kept modest for performance)
    minkowski() {
        cube([max(0.01,size[0]-2*r), max(0.01,size[1]-2*r), max(0.01,size[2]-2*r)], center=true);
        sphere(r=r);
    }
}

module ring_plate(od, id, t) {
    difference() {
        cylinder(d=od, h=t, center=true);
        cylinder(d=id, h=t+0.5, center=true);
    }
}

module ring_terminal() {
    // Coordinate system:
    // X axis along terminal length (ring -> barrel)
    // Z thickness
    union() {
        // Ring
        translate([0,0,0])
            ring_plate(ring_outer_d, ring_inner_d, ring_thickness);

        // Neck (rectangular strap)
        translate([ring_outer_d/2 + neck_length/2 - 0.2, 0, 0])
            rounded_prism([neck_length, neck_width, neck_thickness], r=edge_round);

        // Flare transition (trapezoid prism)
        // Implemented as linear_extrude of a 2D polygon in XY, extruded in Z
        translate([ring_outer_d/2 + neck_length - 0.2, 0, -neck_thickness/2])
            linear_extrude(height=neck_thickness)
                polygon(points=[
                    [0, -neck_width/2],
                    [0,  neck_width/2],
                    [flare_length,  barrel_outer_d/2],
                    [flare_length, -barrel_outer_d/2]
                ]);

        // Barrel (tube)
        translate([ring_outer_d/2 + neck_length + flare_length + barrel_length/2 - 0.2, 0, 0])
            difference() {
                cylinder(d=barrel_outer_d, h=barrel_length, center=true);
                cylinder(d=barrel_inner_d, h=barrel_length+0.6, center=true);
            }

        // Small collar at barrel start for realism
        translate([ring_outer_d/2 + neck_length + flare_length - 0.2, 0, 0])
            difference() {
                cylinder(d=barrel_outer_d+1.2, h=2.2, center=true);
                cylinder(d=barrel_inner_d, h=2.8, center=true);
            }
    }
}

// Slight chamfer-like trimming to soften sharp ends (simple subtract)
module chamfer_trim() {
    // Trim barrel far end
    translate([ring_outer_d/2 + neck_length + flare_length + barrel_length - 0.2, 0, 0])
        rotate([0,90,0])
            cylinder(r=barrel_outer_d, h=2.0, center=true);
}

difference() {
    ring_terminal();
    // Optional: tiny relief at ring/neck junction to avoid perfect tangent
    translate([ring_outer_d/2 - 0.5, 0, 0])
        cylinder(d=ring_inner_d+1.0, h=ring_thickness+0.8, center=true);
}