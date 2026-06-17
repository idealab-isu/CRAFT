// Hex head screw: 4.0mm shank diameter, 8.1mm head diameter (across corners),
// head height 2.925mm, 10mm length under head. One connected solid.

shaft_diameter_mm = 4.0;
length_under_head_mm = 10.0;
head_diameter_across_corners_mm = 8.1;
head_height_mm = 2.925;

overlap_mm = 0.05; // small overlap to ensure watertight union

module hex_head_screw() {
    union() {
        // Shaft (Z from -L to 0)
        translate([0, 0, -length_under_head_mm/2])
            cylinder(h=length_under_head_mm, r=shaft_diameter_mm/2, center=true, $fn=64);

        // Hex head (Z from 0 to head_height)
        // Use $fn=6 for true hex silhouette in orthographic views.
        translate([0, 0, head_height_mm/2 - overlap_mm/2])
            cylinder(h=head_height_mm + overlap_mm, r=head_diameter_across_corners_mm/2, center=true, $fn=6);
    }
}

hex_head_screw();