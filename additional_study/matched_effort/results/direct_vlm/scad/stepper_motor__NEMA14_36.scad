$fn = 96;

// Critical dimensions (mm)
face_w        = 35.2;   // motor face width (square)
body_len      = 36.0;   // motor body length (excluding front plate/boss/shaft)
shaft_d       = 5.0;    // shaft diameter
mount_spacing = 26.0;   // mounting hole center-to-center spacing (square pattern)

// Detail dimensions (mm)
corner_r = 2.0;         // body edge rounding
face_th  = 3.0;         // front face plate thickness
boss_d   = 22.0;        // front boss diameter
boss_h   = 2.0;         // boss height
shaft_len= 20.0;        // shaft protrusion length
hole_d   = 3.2;         // clearance for M3
eps      = 0.2;         // small overlap to ensure watertight unions/differences

module rounded_square_prism(w, h, r){
    // Rounded square prism centered in X/Y, spanning z=[0..h]
    linear_extrude(height=h, center=false)
        offset(r=r)
            square([w-2*r, w-2*r], center=true);
}

module stepper_motor(){
    // Z axis is motor axis; front face is at +Z
    // Body spans z=[0..body_len]
    difference(){
        union(){
            // Main body
            rounded_square_prism(face_w, body_len, corner_r);

            // Front face plate (connected)
            translate([0,0,body_len - eps])
                rounded_square_prism(face_w, face_th + eps, corner_r);

            // Front boss (connected)
            translate([0,0,body_len + face_th - eps])
                cylinder(d=boss_d, h=boss_h + eps, center=false);

            // Shaft (connected)
            translate([0,0,body_len + face_th + boss_h - eps])
                cylinder(d=shaft_d, h=shaft_len + eps, center=false);
        }

        // Mounting holes: through face plate and slightly into body
        hole_start_z = body_len - 1.0; // penetrates into body to guarantee cut
        hole_h = (face_th + boss_h) + 2.0;

        for (x = [-mount_spacing/2, mount_spacing/2])
            for (y = [-mount_spacing/2, mount_spacing/2])
                translate([x, y, hole_start_z])
                    cylinder(d=hole_d, h=hole_h, center=false);

        // Optional shallow center recess on face (kept within face plate only)
        recess_d = 16;
        recess_h = max(0.1, face_th - 0.4);
        translate([0,0,body_len + 0.2])
            cylinder(d=recess_d, h=recess_h, center=false);
    }
}

stepper_motor();