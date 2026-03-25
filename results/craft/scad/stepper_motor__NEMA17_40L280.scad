$fn = 96;

// Target dimensions (mm)
face_width = 42.3;          // square face width (Y/Z)
body_length = 40.0;         // motor body length (X), excluding front plate & rear cap
front_face_thickness = 3.0;
rear_cap_thickness = 2.5;

shaft_diameter = 8.0;
shaft_length = 20.0;

shaft_boss_diameter = 22.0;   // pilot/boss OD
shaft_boss_length = 2.0;      // pilot/boss protrusion

mount_hole_spacing = 31.0;    // NEMA17 pattern (center-to-center)
mount_hole_diameter = 3.5;

center_bore_diameter = 22.0;  // bore around boss (visual/typical)

assembly_overlap = 0.6;       // small overlap to guarantee one connected solid

// Cosmetic details
corner_radius = 2.0;
front_recess_depth = 0.8;
front_recess_margin = 4.0;

// Helpers
module rounded_square_prism(size_xy=42.3, h=10, r=2, center=true) {
    // Rounded rectangle prism via Minkowski (kept robust)
    minkowski() {
        cube([max(0.01, size_xy - 2*r), max(0.01, size_xy - 2*r), h], center=center);
        cylinder(r=r, h=0.01, center=true);
    }
}

module nema17_motor() {
    // Coordinate system:
    // X axis = motor length (shaft points +X)
    // Y/Z = face plane

    union() {
        // --- Main body (square face, rounded corners) ---
        rotate([0, 90, 0])
            rounded_square_prism(size_xy=face_width, h=body_length, r=corner_radius, center=true);

        // --- Front face plate with recess + mounting holes + center bore ---
        translate([ body_length/2 + front_face_thickness/2 - assembly_overlap, 0, 0])
        difference() {
            cube([front_face_thickness, face_width, face_width], center=true);

            // shallow recess (kept inside plate)
            translate([ front_face_thickness/2 - front_recess_depth/2 + 0.01, 0, 0])
                cube([front_recess_depth + 0.02,
                      face_width - 2*front_recess_margin,
                      face_width - 2*front_recess_margin], center=true);

            // center bore
            rotate([0, 90, 0])
                cylinder(d=center_bore_diameter, h=front_face_thickness + 0.4, center=true);

            // 4 mounting holes (31mm spacing)
            for (yy = [-mount_hole_spacing/2, mount_hole_spacing/2])
            for (zz = [-mount_hole_spacing/2, mount_hole_spacing/2])
                translate([0, yy, zz])
                    rotate([0, 90, 0])
                        cylinder(d=mount_hole_diameter, h=front_face_thickness + 0.4, center=true);
        }

        // --- Rear cap ---
        translate([-body_length/2 - rear_cap_thickness/2 + assembly_overlap, 0, 0])
            cube([rear_cap_thickness, face_width, face_width], center=true);

        // --- Shaft boss (pilot) ---
        translate([ body_length/2 + front_face_thickness - assembly_overlap + shaft_boss_length/2, 0, 0])
            rotate([0, 90, 0])
                cylinder(d=shaft_boss_diameter, h=shaft_boss_length, center=true);

        // --- Shaft (8mm) ---
        translate([ body_length/2 + front_face_thickness - assembly_overlap
                    + shaft_boss_length - assembly_overlap + shaft_length/2, 0, 0])
            rotate([0, 90, 0])
                cylinder(d=shaft_diameter, h=shaft_length, center=true);
    }
}

nema17_motor();