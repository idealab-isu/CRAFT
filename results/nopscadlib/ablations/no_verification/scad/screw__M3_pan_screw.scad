// Pan head screw (single connected solid)
// Specs: 3.0mm shaft diameter, 5.4mm head diameter, 2.0mm head height, 10mm length under head

$fn = 96;

// Parameters (mm)
shaft_diameter_mm      = 3.0;
length_under_head_mm   = 10.0;
head_diameter_mm       = 5.4;
head_height_mm         = 2.0;

// Simple Phillips-like recess (optional but kept within head)
recess_depth_mm        = 0.8;
recess_width_mm        = 0.7;
recess_radius_factor   = 0.55;

// Small overlap to ensure watertight union
overlap_mm             = 0.2;

// Derived
shaft_r = shaft_diameter_mm/2;
head_r  = head_diameter_mm/2;

// Pan head profile (rounded top) via rotate_extrude of a 2D section
module pan_head(h=head_height_mm, r=head_r) {
    // z=0 at underside of head, z=h at top
    rotate_extrude(convexity=10)
        polygon(points=[
            [0, 0],
            [r, 0],
            [r, h*0.55],
            [r*0.92, h*0.78],
            [r*0.70, h*0.92],
            [r*0.40, h],
            [0, h]
        ]);
}

module screw() {
    union() {
        // Shaft: from z = -length_under_head to z = 0 (touches head underside)
        translate([0,0,-length_under_head_mm/2])
            cylinder(h=length_under_head_mm + overlap_mm, r=shaft_r, center=true);

        // Head: underside at z=0
        translate([0,0,0])
            difference() {
                pan_head(h=head_height_mm, r=head_r);

                // Recess cut from top, kept shallow
                translate([0,0,head_height_mm - recess_depth_mm])
                    union() {
                        cube([head_diameter_mm*recess_radius_factor*2, recess_width_mm, recess_depth_mm + overlap_mm], center=false);
                        cube([recess_width_mm, head_diameter_mm*recess_radius_factor*2, recess_depth_mm + overlap_mm], center=false);
                    }
            }
    }
}

screw();