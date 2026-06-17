// Thick annular ring (washer/bushing-like) with circular through-bore
// Faceted, slightly irregular outer surface
// Bounding box target: 0.1 x 0.1 x 0.1 mm

// ---------- Parameters ----------
bbox = 0.1;                 // mm (target overall X/Y/Z)
height = bbox;              // mm

outer_radius_max = bbox/2;  // 0.05 mm -> overall diameter 0.1 mm
bore_radius = 0.02;         // circular through-bore radius (mm)

facet_count = 12;           // exterior faceting
facet_radial_depth = 0.003; // how much the facets cut in (mm)
irregularity_amp = 0.001;   // slight irregularity (mm)

chamfer_z = 0.006;          // mm
chamfer_radial = 0.002;     // mm

bore_clearance = 0.002;     // extra height for clean subtraction (mm)

// ---------- Helpers ----------
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

// Ensure outer radius never exceeds bbox/2 after any operation
outer_r = outer_radius_max;
inner_r = clamp(bore_radius, 0, outer_r - 0.001);

// ---------- Geometry ----------
module outer_faceted_irregular_shell() {
    // Start from a true circular cylinder at max radius (guarantees bbox),
    // then subtract shallow "facet" cutters and add tiny irregular bumps.
    difference() {
        // Base outer cylinder (true circle)
        cylinder(h=height, r=outer_r, center=true, $fn=128);

        // Facet cutters: subtract shallow wedges around the perimeter
        // (creates polygonal/faceted exterior while keeping max radius)
        for (i = [0:facet_count-1]) {
            ang = i * 360 / facet_count;

            // Slight per-facet variation (deterministic, no randomness)
            d = facet_radial_depth + irregularity_amp * sin(ang*3);

            // Cutter is a tall box tangent to the cylinder, removing a flat
            rotate([0,0,ang])
                translate([outer_r - d/2, 0, 0])
                    cube([d, 2*outer_r*1.2, height + 2*bore_clearance], center=true);
        }
    }
}

module edge_chamfers() {
    // Subtract small conical frustums at top and bottom outer edge
    union() {
        translate([0, 0, height/2 - chamfer_z/2])
            cylinder(h=chamfer_z, r1=outer_r, r2=outer_r - chamfer_radial, center=true, $fn=96);

        translate([0, 0, -height/2 + chamfer_z/2])
            cylinder(h=chamfer_z, r1=outer_r, r2=outer_r - chamfer_radial, center=true, $fn=96);
    }
}

module circular_through_bore() {
    // Force a truly circular bore with high $fn
    cylinder(h=height + 2*bore_clearance, r=inner_r, center=true, $fn=128);
}

// ---------- Final Solid ----------
difference() {
    // Outer body with faceted/irregular exterior and chamfered edges
    difference() {
        outer_faceted_irregular_shell();
        edge_chamfers();
    }

    // Circular through-hole
    circular_through_bore();
}