$fn = 96;

// Parameters (mm)
face_w = 42.3;          // motor face width (square)
body_len = 47.0;        // motor body length (excluding front boss/shaft)
shaft_d = 5.0;          // shaft diameter
shaft_len = 22.0;       // visible shaft length
mount_spacing = 31.0;   // mounting hole center-to-center spacing
mount_hole_d = 3.2;     // typical NEMA17 clearance for M3
front_boss_d = 22.0;    // typical pilot/boss diameter
front_boss_h = 2.0;     // boss height
corner_r = 3.0;         // slight corner radius for body
face_plate_th = 1.5;    // subtle front face plate thickness

module rounded_square_prism(w, h, r, center=false) {
    // 2D rounded square via offset, then linear_extrude
    linear_extrude(height=h, center=center)
        offset(r=r)
            square([w-2*r, w-2*r], center=true);
}

module stepper_motor() {
    // Body (centered on XY, front face at z=0, body extends to +Z)
    difference() {
        translate([0,0,body_len/2])
            rounded_square_prism(face_w, body_len, corner_r, center=true);

        // Mounting holes through body (along Z)
        for (x = [-mount_spacing/2, mount_spacing/2])
            for (y = [-mount_spacing/2, mount_spacing/2])
                translate([x,y,body_len/2])
                    cylinder(d=mount_hole_d, h=body_len+2, center=true);
    }

    // Front face plate (slight step)
    translate([0,0,face_plate_th/2])
        rounded_square_prism(face_w+0.6, face_plate_th, corner_r, center=true);

    // Front boss/pilot
    translate([0,0,front_boss_h/2])
        cylinder(d=front_boss_d, h=front_boss_h, center=true);

    // Shaft (extends out of front, negative Z)
    translate([0,0,-shaft_len/2])
        cylinder(d=shaft_d, h=shaft_len, center=true);
}

stepper_motor();