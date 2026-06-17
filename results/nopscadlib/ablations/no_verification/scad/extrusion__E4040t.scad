// 40x40 aluminium extrusion profile, 100mm long (single connected solid)

// Parameters (fixed to requested size)
cross_section_width  = 40.0;
cross_section_height = 40.0;
length               = 100.0;

// Profile details
wall_thickness       = 3.0;
slot_opening_width   = 8.0;
slot_depth           = 10.0;
slot_cavity_width    = 14.0;
slot_cavity_depth    = 6.0;

center_bore_diameter = 8.0;
corner_bore_diameter = 5.0;
corner_bore_offset   = 10.0;

overlap              = 0.5;
$fn = 64;

module extrusion_4040(len=length) {
    // Guard against impossible geometry
    w  = cross_section_width;
    h  = cross_section_height;

    // Keep slots within the body
    sd  = min(slot_depth, min(w,h)/2 - wall_thickness);
    scd = min(slot_cavity_depth, sd);
    sow = min(slot_opening_width, min(w,h) - 2*wall_thickness);
    scw = min(slot_cavity_width,  min(w,h) - 2*wall_thickness);

    difference() {
        // Main body
        cube([w, h, len], center=true);

        // Center bore
        cylinder(d=center_bore_diameter, h=len + 2*overlap, center=true);

        // Corner bores
        for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([sx*(w/2 - corner_bore_offset),
                           sy*(h/2 - corner_bore_offset), 0])
                    cylinder(d=corner_bore_diameter, h=len + 2*overlap, center=true);

        // T-slots on +/-X faces
        for (sx = [-1, 1]) {
            // Opening (near outer face)
            translate([sx*(w/2 - (sd + overlap)/2), 0, 0])
                cube([sd + overlap, sow, len + 2*overlap], center=true);

            // Inner cavity (deeper inside)
            translate([sx*(w/2 - sd - (scd + overlap)/2 + overlap), 0, 0])
                cube([scd + overlap, scw, len + 2*overlap], center=true);
        }

        // T-slots on +/-Y faces
        for (sy = [-1, 1]) {
            translate([0, sy*(h/2 - (sd + overlap)/2), 0])
                cube([sow, sd + overlap, len + 2*overlap], center=true);

            translate([0, sy*(h/2 - sd - (scd + overlap)/2 + overlap), 0])
                cube([scw, scd + overlap, len + 2*overlap], center=true);
        }
    }
}

// Single connected solid only (no extra floating parts)
color("Silver") extrusion_4040(length);