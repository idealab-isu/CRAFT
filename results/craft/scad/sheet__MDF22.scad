// Parameters
sheet_length = 600; //[300:1200:1]
sheet_width  = 400; //[200:800:1]
sheet_thickness = 18; //[9:36:1]
corner_radius = 12; //[6:24:1]
edge_chamfer = 2; //[1:6:1]
overlap = 1; //[0.5:2:0.5]

// Simple rectangular MDF sheet (optionally with rounded corners)
// NOTE: No chamfers, textures, or labels to keep orthographic silhouettes rectangular.

$fn = 64;

module mdf_sheet() {
    // Clamp radius so it cannot exceed half of the smallest side
    r = min(corner_radius, sheet_length/2, sheet_width/2);

    if (r <= 0) {
        cube([sheet_length, sheet_width, sheet_thickness], center=true);
    } else {
        linear_extrude(height=sheet_thickness, center=true)
            offset(r=r)
                square([sheet_length - 2*r, sheet_width - 2*r], center=true);
    }
}

mdf_sheet();