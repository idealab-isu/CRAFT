// EPCOS B57560G104F style radial NTC thermistor (disc + two wire leads)
// Structural fix: make silhouette clearly "disc body + two leads" and ensure
// ALL parts are connected into ONE coherent solid with small overlaps.

$fn = 72;

// Parameters (mm)
body_diameter = 3.2;           //[1.6:6.4:0.1]
body_thickness = 2.0;          //[1.0:4.0:0.1]

lead_diameter = 0.5;           //[0.25:1.0:0.05]
lead_length = 25.0;            //[12.5:50.0:0.5]
lead_pitch = 2.5;              //[1.25:5.0:0.1]

neck_length = 0.8;             //[0.4:2.0:0.1]
neck_diameter = 0.9;           //[0.5:1.6:0.05]

lead_straight_from_body = 6.0; //[3.0:12.0:0.5]
bend_enabled = 1;              //[0:1:1]
bend_drop = 3.0;               //[0.0:8.0:0.5]

sleeve_enabled = 1;            //[0:1:1]
sleeve_length = 3.0;           //[1.5:8.0:0.5]
sleeve_diameter = 0.9;         //[0.6:2.0:0.1]

marking_flat_depth = 0.25;     //[0.1:0.6:0.05]

// Overlap to guarantee manifold unions (1–2mm requested)
overlap = 1.2;

// Derived
body_r   = body_diameter/2;
lead_r   = lead_diameter/2;
neck_r   = neck_diameter/2;
sleeve_r = sleeve_diameter/2;

// Clamp to sane values
lead_straight_from_body = min(lead_straight_from_body, lead_length);
post_bend_len = max(0, lead_length - lead_straight_from_body);
drop = (bend_enabled ? bend_drop : 0);

// Coordinate system:
// - Body disc centered at origin, thickness along X (leads exit +X face)
// - Leads run along +X, spaced along Y by lead_pitch

module disc_body_with_flat() {
    // Disc along X
    difference() {
        rotate([0,90,0])
            cylinder(r=body_r, h=body_thickness, center=true);

        // Flat on +Y side (small chord flat), shallow cut
        translate([0, body_r - marking_flat_depth, 0])
            cube([body_thickness + 2*overlap, 2*body_r, 2*body_r], center=true);
    }
}

module necks() {
    // Necks start at +X face of body and extend outward.
    // Use overlap so they penetrate the body and also reach into the lead.
    x_body_face = body_thickness/2;

    // Place neck so its -X end is inside the body by "overlap"
    // Neck spans: [x_body_face - overlap, x_body_face + neck_length + overlap]
    x_center = x_body_face + neck_length/2;

    for (sy = [-1, 1]) {
        translate([x_center, sy*lead_pitch/2, 0])
            rotate([0,90,0])
                cylinder(r=neck_r, h=neck_length + 2*overlap, center=true);
    }
}

module lead_with_optional_bend(ypos) {
    // Lead path:
    // Segment A: straight along +X from end of neck
    // Segment B: vertical drop in -Z at the bend point (if enabled)
    // Segment C: straight along +X after bend at lowered Z (if enabled)
    // All segments overlap to ensure one connected solid.

    x_body_face = body_thickness/2;

    // Actual neck solid ends at: x_body_face + neck_length + overlap
    // Start lead A slightly inside that to guarantee union.
    x_neck_solid_end = x_body_face + neck_length + overlap;
    xA_start = x_neck_solid_end - overlap; // inside neck by overlap

    segA_len = lead_straight_from_body;
    xA_center = xA_start + segA_len/2;

    translate([xA_center, ypos, 0])
        rotate([0,90,0])
            cylinder(r=lead_r, h=segA_len + 2*overlap, center=true);

    if (bend_enabled && drop > 0 && post_bend_len > 0) {
        // Bend location at end of segment A (with overlap)
        x_bend = xA_start + segA_len;

        // Segment B (vertical drop), centered so it overlaps segment A and C
        translate([x_bend - overlap, ypos, -drop/2])
            cylinder(r=lead_r, h=drop + 2*overlap, center=true);

        // Segment C (post-bend straight), start slightly before bend for overlap
        xC_start = x_bend - overlap;
        xC_center = xC_start + post_bend_len/2;

        translate([xC_center, ypos, -drop])
            rotate([0,90,0])
                cylinder(r=lead_r, h=post_bend_len + 2*overlap, center=true);
    } else {
        // No bend: extend remaining length straight
        rem = max(0, lead_length - segA_len);
        if (rem > 0) {
            xC_start = xA_start + segA_len - overlap;
            xC_center = xC_start + rem/2;

            translate([xC_center, ypos, 0])
                rotate([0,90,0])
                    cylinder(r=lead_r, h=rem + 2*overlap, center=true);
        }
    }
}

module sleeves() {
    if (sleeve_enabled) {
        // Sleeve placed on the first part of the lead, starting right after neck.
        // Ensure it overlaps the neck and lead segment A.
        x_body_face = body_thickness/2;

        // Neck solid ends at x_body_face + neck_length + overlap
        x_neck_solid_end = x_body_face + neck_length + overlap;

        usable = min(sleeve_length, lead_straight_from_body);
        if (usable > 0) {
            // Start sleeve slightly inside neck for union
            xS_start = x_neck_solid_end - overlap;
            x_center = xS_start + usable/2;

            for (sy = [-1, 1]) {
                translate([x_center, sy*lead_pitch/2, 0])
                    rotate([0,90,0])
                        cylinder(r=sleeve_r, h=usable + 2*overlap, center=true);
            }
        }
    }
}

module complete_model() {
    union() {
        // Recognizable thermistor body + two leads (single coherent component)
        disc_body_with_flat();
        necks();
        sleeves();

        // Two wire leads
        lead_with_optional_bend( lead_pitch/2);
        lead_with_optional_bend(-lead_pitch/2);
    }
}

complete_model();