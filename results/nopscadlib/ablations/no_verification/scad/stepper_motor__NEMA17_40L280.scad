$fn = 96;

// Target dimensions (mm)
face_width         = 42.3;
body_length        = 40.0;
body_width         = 42.3;

shaft_diameter     = 8.0;
shaft_length       = 20.0;

mount_hole_spacing = 31.0;
mount_hole_diameter= 3.5;

// Detail (kept reasonable for a typical NEMA17-like motor)
corner_radius      = 3.0;     // rounded body corners
face_thickness     = 3.0;     // front plate thickness
front_boss_diameter= 22.0;    // pilot/boss
front_boss_height  = 2.0;

rear_boss_diameter = 22.0;    // rear bearing boss (visual)
rear_boss_height   = 1.5;

back_cap_thickness = 2.0;     // rear cap thickness

connector_w        = 16.0;    // rear connector block
connector_h        = 10.0;
connector_d        = 6.0;

overlap            = 0.6;     // small overlap to ensure single connected solid

// ---------- Helpers ----------
module rounded_square_prism(w, h, r, center=true) {
    // 2D rounded square extruded
    linear_extrude(height=h, center=center)
        offset(r=r)
            square([w-2*r, w-2*r], center=true);
}

module mount_holes(h, zc) {
    for (x = [-mount_hole_spacing/2, mount_hole_spacing/2])
        for (y = [-mount_hole_spacing/2, mount_hole_spacing/2])
            translate([x, y, zc])
                cylinder(h=h, r=mount_hole_diameter/2, center=true);
}

// ---------- Motor (single connected solid) ----------
module stepper_motor() {
    difference() {
        union() {
            // Main body with rounded corners
            rounded_square_prism(body_width, body_length, corner_radius, center=true);

            // Front face plate (slightly proud)
            translate([0, 0, body_length/2 - face_thickness/2 + overlap])
                cube([face_width, face_width, face_thickness], center=true);

            // Front boss/pilot
            translate([0, 0, body_length/2 + front_boss_height/2 - overlap])
                cylinder(h=front_boss_height, r=front_boss_diameter/2, center=true);

            // Shaft (connected to boss)
            translate([0, 0, body_length/2 + front_boss_height + shaft_length/2 - overlap])
                cylinder(h=shaft_length, r=shaft_diameter/2, center=true);

            // Rear cap (slightly proud)
            translate([0, 0, -body_length/2 + back_cap_thickness/2 - overlap])
                cube([face_width, face_width, back_cap_thickness], center=true);

            // Rear boss (visual bearing boss)
            translate([0, 0, -body_length/2 - rear_boss_height/2 + overlap])
                cylinder(h=rear_boss_height, r=rear_boss_diameter/2, center=true);

            // Rear connector block (attached to rear cap)
            translate([0, -face_width/2 + connector_d/2 - overlap, -body_length/2 + back_cap_thickness/2 - overlap])
                cube([connector_w, connector_d, connector_h], center=true);
        }

        // Through mounting holes (visible on front face)
        // Drill from slightly in front of face plate through into body
        mount_holes(
            h = face_thickness + 2*overlap + 6, // enough to clearly cut into body
            zc = body_length/2 - face_thickness/2 + overlap
        );

        // Small front recess ring around boss (adds typical face detail)
        translate([0, 0, body_length/2 - face_thickness/2 + overlap])
            difference() {
                cylinder(h=face_thickness + 2*overlap, r=front_boss_diameter/2 + 2.0, center=true);
                cylinder(h=face_thickness + 2*overlap + 0.2, r=front_boss_diameter/2 + 0.6, center=true);
            }
    }
}

stepper_motor();