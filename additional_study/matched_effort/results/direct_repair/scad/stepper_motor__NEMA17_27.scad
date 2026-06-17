$fn = 96;

// NEMA-style stepper motor (approx) per given dimensions
face_w = 42.3;          // square face width
body_len = 26.5;        // motor body length (excluding shaft)
shaft_d = 5.0;          // shaft diameter
mount_spacing = 31.0;   // mounting hole center-to-center spacing (square pattern)

// Reasonable defaults for unspecified details
corner_r = 3.0;         // face corner radius
face_plate_th = 2.0;    // front face plate thickness
pilot_d = 22.0;         // front pilot/boss diameter (typical)
pilot_h = 2.0;          // pilot height
shaft_len = 20.0;       // shaft protrusion length
mount_hole_d = 3.4;     // clearance for M3

module rounded_square_2d(w, r){
    r2 = min(r, w/2);
    hull(){
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r2), sy*(w/2 - r2)]) circle(r=r2);
    }
}

module motor_body(){
    // Main body with rounded corners
    linear_extrude(height=body_len)
        rounded_square_2d(face_w, corner_r);
}

module face_plate(){
    // Slightly emphasized front plate
    linear_extrude(height=face_plate_th)
        rounded_square_2d(face_w, corner_r);
}

module pilot(){
    cylinder(d=pilot_d, h=pilot_h);
}

module shaft(){
    cylinder(d=shaft_d, h=shaft_len);
}

module mount_holes(h){
    for (x = [-mount_spacing/2, mount_spacing/2])
        for (y = [-mount_spacing/2, mount_spacing/2])
            translate([x, y, -0.1]) cylinder(d=mount_hole_d, h=h+0.2);
}

module stepper_motor(){
    // Coordinate system: front face at z=0, body extends to +z, shaft extends to -z
    difference(){
        union(){
            // Body
            translate([0,0,0]) motor_body();

            // Front face plate (flush at front)
            translate([0,0,0]) face_plate();

            // Pilot boss
            translate([0,0,-pilot_h]) pilot();

            // Shaft
            translate([0,0,-(pilot_h + shaft_len)]) shaft();
        }

        // Mounting holes through face plate and into body a bit
        mount_holes(face_plate_th + 6);
    }
}

stepper_motor();