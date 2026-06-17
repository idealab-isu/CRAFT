$fn = 96;

// Parameters (mm)
face_w = 35.2;          // motor face width (square)
body_len = 36.0;        // motor body length (excluding shaft)
shaft_d = 5.0;          // shaft diameter
shaft_len = 20.0;       // assumed shaft protrusion length
mount_spacing = 26.0;   // mounting hole center-to-center spacing
mount_hole_d = 3.2;     // typical M3 clearance
face_plate_th = 2.0;    // front face plate thickness (visual)
pilot_d = 22.0;         // typical NEMA pilot diameter (visual)
pilot_h = 1.8;          // pilot height (visual)
corner_r = 2.0;         // body corner radius (visual)

// Helpers
module rounded_square_prism(w, h, r, center=false) {
    // 2D rounded square via hull of circles, then linear_extrude
    linear_extrude(height=h, center=center)
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(w/2 - r), sy*(w/2 - r)]) circle(r=r);
        }
}

module stepper_motor() {
    // Body
    color([0.25,0.25,0.25])
    translate([0,0,0])
    rounded_square_prism(face_w, body_len, corner_r, center=false);

    // Front face plate (slightly larger, thin)
    color([0.35,0.35,0.35])
    translate([0,0,body_len - face_plate_th])
    rounded_square_prism(face_w + 0.6, face_plate_th, corner_r, center=false);

    // Pilot boss
    color([0.55,0.55,0.55])
    translate([0,0,body_len])
    cylinder(d=pilot_d, h=pilot_h, center=false);

    // Shaft
    color([0.75,0.75,0.75])
    translate([0,0,body_len + pilot_h])
    cylinder(d=shaft_d, h=shaft_len, center=false);

    // Mounting holes (through front plate + a bit into body for visibility)
    // Represented as cutouts in a thin "front region" for render clarity
    difference() {
        // front region to subtract from (invisible)
        translate([0,0,body_len - 6])
            cube([face_w + 2, face_w + 2, 8], center=true);
        for (x = [-mount_spacing/2, mount_spacing/2])
            for (y = [-mount_spacing/2, mount_spacing/2])
                translate([x,y,body_len - 10])
                    cylinder(d=mount_hole_d, h=20, center=false);
    }
}

stepper_motor();