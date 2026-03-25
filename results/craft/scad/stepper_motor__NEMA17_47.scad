$fn = 96;

// Target dimensions (mm)
face_width_mm = 42.3;                 // square face width
body_length_mm = 47.0;                // motor body length (excluding front boss/shaft)
shaft_diameter_mm = 5.0;              // shaft diameter
mounting_hole_spacing_mm = 31.0;      // NEMA17 hole spacing (center-to-center)

// Typical/derived details (kept parametric)
face_thickness_mm = 3.5;              // front plate thickness
corner_radius_mm = 2.0;               // body corner radius
shaft_length_mm = 20.0;               // front shaft protrusion
shaft_boss_diameter_mm = 22.0;        // front boss diameter
shaft_boss_height_mm = 2.0;           // front boss height
rear_boss_diameter_mm = 18.0;         // rear cable/shaft boss (visual)
rear_boss_height_mm = 2.0;            // rear boss height
mounting_hole_diameter_mm = 3.2;      // clearance for M3
overlap_mm = 0.6;                     // small overlap to ensure watertight union

// Convenience
body_w = face_width_mm;
z_front = 0;                          // front face plane reference
z_body_center = -(face_thickness_mm/2 + body_length_mm/2 - overlap_mm);

// Rounded rectangular prism (Z height = h)
module rounded_box_xy(w, d, h, r) {
    // Uses hull of corner cylinders for robust rounded rectangle
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r), sy*(d/2 - r), 0])
                cylinder(r=r, h=h, center=true);
    }
}

module motor_solid() {
    union() {
        // Main body (rounded)
        translate([0, 0, z_body_center])
            rounded_box_xy(body_w, body_w, body_length_mm, corner_radius_mm);

        // Front faceplate (slightly larger/clean edge)
        translate([0, 0, -(face_thickness_mm/2 - overlap_mm)])
            cube([face_width_mm, face_width_mm, face_thickness_mm], center=true);

        // Front boss (pilot/boss)
        translate([0, 0, face_thickness_mm/2 + shaft_boss_height_mm/2 - overlap_mm])
            cylinder(d=shaft_boss_diameter_mm, h=shaft_boss_height_mm, center=true);

        // Shaft
        translate([0, 0, face_thickness_mm/2 + shaft_length_mm/2 - overlap_mm])
            cylinder(d=shaft_diameter_mm, h=shaft_length_mm, center=true);

        // Rear boss (visual feature; keeps one connected solid)
        translate([0, 0, -(face_thickness_mm + body_length_mm) + rear_boss_height_mm/2 + overlap_mm])
            cylinder(d=rear_boss_diameter_mm, h=rear_boss_height_mm, center=true);
    }
}

module mounting_holes_cut() {
    // Through-holes along Z, centered on the face
    hole_h = face_thickness_mm + body_length_mm + shaft_boss_height_mm + rear_boss_height_mm + 10;
    z_hole_center = -(face_thickness_mm/2 + body_length_mm/2); // roughly through motor

    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*mounting_hole_spacing_mm/2, sy*mounting_hole_spacing_mm/2, z_hole_center])
            cylinder(d=mounting_hole_diameter_mm, h=hole_h, center=true);
    }
}

difference() {
    motor_solid();
    mounting_holes_cut();
}