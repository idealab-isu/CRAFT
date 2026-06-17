// Miniature linear guide rail (single connected solid)
// Overall: 15.0mm wide (X), 12.5mm tall (Z), 100mm long (Y)

$fn = 64;

// Parameters
rail_length = 100.0;          // Y
rail_width  = 15.0;           // X
rail_height = 12.5;           // Z

feature_overlap = 0.6;        // small overlap to avoid coplanar artifacts
chamfer_size = 1.0;           // end chamfer size
mount_hole_diameter = 3.5;    // through holes
mount_hole_csk_diameter = 6.2;// shallow counterbore
mount_hole_csk_depth = 1.2;   // counterbore depth

// Profile features (kept proportional and within overall envelope)
top_land_w = rail_width * 0.55;     // flat top width
top_land_h = rail_height * 0.28;    // top land height
base_h     = rail_height - top_land_h;

side_groove_depth = rail_width * 0.12; // how far grooves cut in from each side
side_groove_h     = rail_height * 0.42;
side_groove_z0    = rail_height * 0.30; // groove vertical placement

center_relief_w = rail_width * 0.22;    // small bottom relief channel
center_relief_h = rail_height * 0.18;

// Mounting hole pattern
hole_count = 5;
end_margin = 10.0; // from each end along Y
hole_pitch = (rail_length - 2*end_margin) / (hole_count - 1);

// Helpers
module chamfered_end_cuts() {
    // Cut 45° chamfers at both ends (Y- and Y+)
    // Use rotated cubes as cutters; formulas ensure they touch the ends.
    for (s = [-1, 1]) {
        translate([0, s*(rail_length/2 - chamfer_size/2), rail_height/2])
            rotate([45*s, 0, 0])
                cube([rail_width + 2, chamfer_size*2, rail_height + 2], center=true);
    }
}

module mounting_hole_cuts() {
    // Through holes + shallow counterbore from top
    for (i = [0:hole_count-1]) {
        y = -rail_length/2 + end_margin + i*hole_pitch;

        // Through hole
        translate([0, y, 0])
            cylinder(h=rail_height + 2, d=mount_hole_diameter, center=true);

        // Counterbore (from top face down)
        translate([0, y, rail_height/2 - mount_hole_csk_depth/2 + feature_overlap/2])
            cylinder(h=mount_hole_csk_depth + feature_overlap, d=mount_hole_csk_diameter, center=true);
    }
}

module rail_solid() {
    // Build a recognizable rail profile by starting from a block and subtracting grooves/reliefs/holes/chamfers.
    difference() {
        // Base block (overall envelope)
        cube([rail_width, rail_length, rail_height], center=true);

        // Side grooves (two long channels)
        for (sx = [-1, 1]) {
            translate([sx*(rail_width/2 - side_groove_depth/2), 0, -rail_height/2 + side_groove_z0 + side_groove_h/2])
                cube([side_groove_depth + feature_overlap, rail_length + 2, side_groove_h], center=true);
        }

        // Bottom center relief channel (long)
        translate([0, 0, -rail_height/2 + center_relief_h/2])
            cube([center_relief_w, rail_length + 2, center_relief_h + feature_overlap], center=true);

        // Shape the top into a narrower land by cutting shoulders along the length
        // Remove material on both sides above base_h to create a "rail head".
        for (sx = [-1, 1]) {
            translate([sx*((top_land_w/2) + (rail_width - top_land_w)/4), 0, -rail_height/2 + base_h + top_land_h/2])
                cube([(rail_width - top_land_w)/2 + feature_overlap, rail_length + 2, top_land_h + 2], center=true);
        }

        // End chamfers
        chamfered_end_cuts();

        // Mounting holes
        mounting_hole_cuts();
    }
}

// Final output (single connected solid)
color("Silver")
rail_solid();