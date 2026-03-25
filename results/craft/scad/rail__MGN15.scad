// Miniature linear guide rail (MGN15-style) - 15mm wide, 10mm tall, 100mm long
// One connected solid (holes/grooves are subtracted but rail remains a single manifold body).

$fn = 64;

// Parameters
width_mm  = 15;   //[7.5:30:0.5]
height_mm = 10;   //[5:20:0.5]
length_mm = 100;  //[50:200:1]

// Feature parameters (kept proportional to overall size)
edge_chamfer = min(0.8, width_mm*0.06);          // small edge break
top_land     = width_mm*0.20;                    // flat land on top center
groove_depth = min(1.2, height_mm*0.18);         // side raceway groove depth
groove_h     = min(3.2, height_mm*0.32);         // groove vertical size
groove_zc    = height_mm*0.55;                   // groove center height (from bottom)

hole_d       = 4.2;                              // typical MGN15 mounting hole clearance-ish
csk_d        = 7.6;                              // counterbore diameter
csk_h        = min(2.2, height_mm*0.25);         // counterbore depth
end_margin   = max(8, length_mm*0.08);           // keep holes away from ends
hole_pitch   = 20;                               // typical spacing
hole_count   = max(3, floor((length_mm - 2*end_margin)/hole_pitch) + 1);

module rail_body() {
    // Base prism with subtle chamfers via hull of slightly inset top/bottom rectangles
    // Ensures a visible, non-blank model and more rail-like silhouette.
    hull() {
        // Bottom rectangle (full width)
        translate([0, 0, 0])
            linear_extrude(height=length_mm, center=true)
                square([width_mm, height_mm*0.02], center=true);

        // Mid rectangle (full width, gives thickness)
        translate([0, 0, 0])
            linear_extrude(height=length_mm, center=true)
                square([width_mm, height_mm], center=true);

        // Top rectangle (slightly inset to create chamfered edges)
        translate([0, 0, 0])
            linear_extrude(height=length_mm, center=true)
                square([width_mm - 2*edge_chamfer, height_mm - 2*edge_chamfer], center=true);
    }
}

module rail_profile_solid() {
    // Create a more rail-like cross-section by adding a top "crown" land
    // (still within overall width/height envelope).
    union() {
        // Main body
        cube([width_mm, length_mm, height_mm], center=true);

        // Slight top ridge (kept within width/height; adds recognizable feature)
        ridge_w = max(top_land, 2);
        ridge_h = min(1.2, height_mm*0.12);
        translate([0, 0, height_mm/2 - ridge_h/2])
            cube([ridge_w, length_mm, ridge_h], center=true);
    }
}

module raceway_grooves() {
    // Subtract shallow side grooves along the full length
    // Positioned by formulas so they always cut into the rail.
    groove_w = groove_depth;
    groove_y = length_mm + 2; // ensure full cut through length
    translate([ width_mm/2 - groove_w/2, 0, -height_mm/2 + groove_zc])
        cube([groove_w, groove_y, groove_h], center=true);

    translate([-width_mm/2 + groove_w/2, 0, -height_mm/2 + groove_zc])
        cube([groove_w, groove_y, groove_h], center=true);
}

module mounting_holes() {
    // Through holes + counterbores from the top face
    // Holes run along Y (length axis). Rail is [X=width, Y=length, Z=height].
    start_y = -length_mm/2 + end_margin;
    for (i = [0:hole_count-1]) {
        y = start_y + i*hole_pitch;
        if (y <= length_mm/2 - end_margin + 0.001) {
            // Through hole (Z axis)
            translate([0, y, 0])
                cylinder(d=hole_d, h=height_mm + 2, center=true);

            // Counterbore from top
            translate([0, y, height_mm/2 - csk_h/2])
                cylinder(d=csk_d, h=csk_h + 0.2, center=true);
        }
    }
}

module MGN15_rail() {
    color("Silver")
    difference() {
        // Solid rail (single connected body)
        rail_profile_solid();

        // Subtractive features
        raceway_grooves();
        mounting_holes();
    }
}

// Assembly
MGN15_rail();