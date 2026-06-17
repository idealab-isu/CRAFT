$fn=180;

// Radial encoder magnet (ring magnet with alternating N/S poles around the circumference)
// Geometry only; polarity pattern is represented as shallow alternating grooves on the top face.

outer_d = 20;          // mm
inner_d = 6;           // mm (shaft hole)
thickness = 3;         // mm

// Visual pole-marking pattern (shallow grooves)
pole_count = 12;       // number of alternating poles around the ring
mark_depth = 0.25;     // mm
mark_width_deg = 360/(pole_count*2) * 0.75; // groove angular width (fraction of half-pole)
mark_r1 = inner_d/2 + 0.6;                  // start radius of marking
mark_r2 = outer_d/2 - 0.6;                  // end radius of marking

module ring_magnet(od, id, h) {
    difference() {
        cylinder(d=od, h=h);
        translate([0,0,-0.1]) cylinder(d=id, h=h+0.2);
    }
}

module groove_sector(r1, r2, ang_deg, h) {
    // Creates a wedge-shaped sector (in XY) extruded in Z
    linear_extrude(height=h)
        polygon(points=[
            [0,0],
            [r2*cos(-ang_deg/2), r2*sin(-ang_deg/2)],
            [r2*cos( ang_deg/2), r2*sin( ang_deg/2)],
            [r1*cos( ang_deg/2), r1*sin( ang_deg/2)],
            [r1*cos(-ang_deg/2), r1*sin(-ang_deg/2)]
        ]);
}

module pole_marks(poles, r1, r2, width_deg, depth, z_top) {
    // Alternate grooves every other half-pole to indicate N/S pattern
    half_step = 360/(poles*2);
    for (i = [0 : poles*2 - 1]) {
        if (i % 2 == 0) {
            rotate([0,0,i*half_step])
                translate([0,0,z_top - depth])
                    groove_sector(r1, r2, width_deg, depth + 0.02);
        }
    }
}

difference() {
    ring_magnet(outer_d, inner_d, thickness);
    pole_marks(pole_count, mark_r1, mark_r2, mark_width_deg, mark_depth, thickness);
}