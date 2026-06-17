$fn = 96;

// Target dimensions
face_width          = 42.3;   // mm (front square)
face_thickness      = 3.0;    // mm (front plate thickness)
body_length         = 34.0;   // mm (main body length behind face)
body_width          = 42.3;   // mm (body square)
shaft_diameter      = 5.0;    // mm
shaft_length        = 20.0;   // mm
mount_hole_spacing  = 31.0;   // mm (square pattern)
mount_hole_diameter = 3.5;    // mm (clearance)
overlap             = 0.4;    // mm (boolean robustness)

// Typical stepper front details (visual only; does not change requested critical dims)
boss_diameter       = 22.0;   // mm (front boss/bearing area)
boss_height         = 2.0;    // mm (protrusion from face)
pilot_diameter      = 10.0;   // mm (small raised ring around shaft)
pilot_height        = 0.8;    // mm

// Body corner relief (visual)
corner_relief_r     = 4.0;    // mm (rounding at body corners)

// Rear connector block (kept connected to body)
d_plug_length       = 18.0;
d_plug_width        = 12.0;
d_plug_thickness    = 6.0;

// Small rear "rail" bumps (kept connected)
rail_bump_diameter  = 4.0;
rail_bump_height    = 1.2;

// Derived Z locations (front face centered at z=0; shaft on +Z only)
z_face_center = 0;
z_face_front  = z_face_center + face_thickness/2;
z_face_back   = z_face_center - face_thickness/2;

z_body_front  = z_face_back;                 // body touches face back
z_body_back   = z_body_front - body_length;  // rear end of body
z_body_center = (z_body_front + z_body_back)/2;

module rounded_square_prism(w, h, r) {
    // w: width in X/Y, h: height in Z, r: corner radius
    linear_extrude(height=h, center=true)
        offset(r=r)
            square([w - 2*r, w - 2*r], center=true);
}

module stepper_motor() {
    difference() {
        union() {
            // Front face plate
            translate([0,0,z_face_center])
                cube([face_width, face_width, face_thickness], center=true);

            // Main body with rounded corners (connected to face)
            translate([0,0,z_body_center])
                rounded_square_prism(body_width, body_length, corner_relief_r);

            // Front boss/bearing area (connected to face)
            translate([0,0,z_face_front + boss_height/2 - overlap])
                cylinder(d=boss_diameter, h=boss_height, center=true);

            // Small pilot ring around shaft (connected to boss/face)
            translate([0,0,z_face_front + pilot_height/2 - overlap])
                cylinder(d=pilot_diameter, h=pilot_height, center=true);

            // Shaft (connected to pilot/boss/face) - ALWAYS on +Z side
            translate([0,0,z_face_front + shaft_length/2 - overlap])
                cylinder(d=shaft_diameter, h=shaft_length, center=true);

            // Rear connector block (connected to rear of body)
            translate([0,0,z_body_back - d_plug_thickness/2 + overlap])
                cube([d_plug_length, d_plug_width, d_plug_thickness], center=true);

            // Rear small bumps (connected)
            for (x = [-body_width/4, body_width/4])
                translate([x, 0, z_body_back - rail_bump_height/2 + overlap])
                    cylinder(d=rail_bump_diameter, h=rail_bump_height, center=true);
        }

        // 4 mounting holes: through the face and slightly into body (kept aligned to 31mm spacing)
        hole_h = face_thickness + 2.0 + 2*overlap;
        hole_z = z_face_back - 1.0; // start slightly behind face front; cylinder is not centered
        for (x = [-mount_hole_spacing/2, mount_hole_spacing/2])
            for (y = [-mount_hole_spacing/2, mount_hole_spacing/2])
                translate([x, y, hole_z])
                    cylinder(d=mount_hole_diameter, h=hole_h, center=false);
    }
}

stepper_motor();