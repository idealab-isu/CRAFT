$fn = 128;

// Target dimensions (mm)
inner_diameter = 10.0; // Bore
outer_diameter = 19.0; // OD
length         = 29.0; // Overall length

// Simple visual features (still one connected solid)
seal_thickness = 1.0;   // End seal depth
seal_lip_rad   = 0.35;  // Small OD lip for seal look
groove_depth   = 0.35;  // Shallow OD grooves
groove_width   = 1.2;
groove_offset  = 4.0;   // From each end

eps = 0.02;

module linear_bearing_10x19x29() {
    difference() {
        // Outer body with slight seal lips (connected, no floating parts)
        union() {
            // Main sleeve
            cylinder(h = length, d = outer_diameter, center = true);

            // Seal lips at both ends (slightly larger OD, overlapping into body)
            translate([0, 0,  length/2 - seal_thickness/2])
                cylinder(h = seal_thickness + eps, d = outer_diameter + 2*seal_lip_rad, center = true);
            translate([0, 0, -length/2 + seal_thickness/2])
                cylinder(h = seal_thickness + eps, d = outer_diameter + 2*seal_lip_rad, center = true);
        }

        // Through bore (centered, guaranteed to cut through)
        cylinder(h = length + 2*eps, d = inner_diameter, center = true);

        // Shallow OD grooves near ends (bearing-like detail)
        translate([0, 0,  length/2 - groove_offset])
            cylinder(h = groove_width, d = outer_diameter - 2*groove_depth, center = true);
        translate([0, 0, -length/2 + groove_offset])
            cylinder(h = groove_width, d = outer_diameter - 2*groove_depth, center = true);
    }
}

linear_bearing_10x19x29();