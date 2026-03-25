$fn = 128;

// Target: LM8LUU-style long linear bearing
bore_diameter_mm  = 8.0;
outer_diameter_mm = 15.0;
length_mm         = 45.0;

bore_clearance_mm = 0.15;   // small clearance for visible bore
overlap_mm        = 0.2;    // for robust boolean ops

// Exterior details (typical rings/grooves + end chamfers)
ring_width_mm     = 3.0;
ring_depth_mm     = 0.6;
ring_inset_mm     = 6.0;    // distance from each end to ring center
chamfer_mm        = 0.8;    // end chamfer length

module linear_bearing_LM8LUU(bore_d=bore_diameter_mm,
                            od=outer_diameter_mm,
                            L=length_mm) {

    bore_r  = bore_d/2 + bore_clearance_mm;
    outer_r = od/2;

    // Keep rings within the body
    ring_center_from_end = min(ring_inset_mm, (L/2 - ring_width_mm/2 - chamfer_mm - 0.5));
    ring_z = (L/2 - ring_center_from_end);

    difference() {
        // Outer body with end chamfers (frustum ends)
        union() {
            // Main straight section
            cylinder(r=outer_r, h=L - 2*chamfer_mm, center=true);

            // End chamfers
            translate([0,0, (L/2 - chamfer_mm/2)])
                cylinder(r1=outer_r, r2=outer_r - chamfer_mm, h=chamfer_mm, center=true);
            translate([0,0, -(L/2 - chamfer_mm/2)])
                cylinder(r1=outer_r - chamfer_mm, r2=outer_r, h=chamfer_mm, center=true);
        }

        // Through bore
        cylinder(r=bore_r, h=L + 2*overlap_mm, center=true);

        // Two exterior grooves (rings)
        translate([0,0,  ring_z])
            cylinder(r=outer_r - ring_depth_mm, h=ring_width_mm, center=true);
        translate([0,0, -ring_z])
            cylinder(r=outer_r - ring_depth_mm, h=ring_width_mm, center=true);
    }
}

// One connected solid: just the bearing (no floating side screw/rod)
linear_bearing_LM8LUU();