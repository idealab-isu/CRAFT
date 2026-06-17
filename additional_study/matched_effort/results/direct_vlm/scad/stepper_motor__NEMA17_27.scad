$fn = 96;

// NEMA-style stepper motor (approx) per given dimensions
face_w = 42.3;          // square face width
body_len = 26.5;        // body length (excluding front boss/shaft)
shaft_d = 5.0;          // shaft diameter
mount_spacing = 31.0;   // mounting hole center-to-center spacing

// Reasonable defaults for unspecified features
corner_r = 3.0;         // rounded corner radius
front_boss_d = 22.0;    // typical pilot/boss diameter
front_boss_h = 2.0;     // boss height
mount_hole_d = 3.2;     // clearance for M3
shaft_len = 20.0;       // visible shaft length
back_cap_h = 2.0;       // slight rear cap

module rounded_square_prism(w, h, r){
    linear_extrude(height=h)
        offset(r=r)
            square([w-2*r, w-2*r], center=true);
}

module stepper_motor(){
    difference(){
        union(){
            // Main body
            translate([0,0,0])
                rounded_square_prism(face_w, body_len, corner_r);

            // Rear cap (slight)
            translate([0,0,-back_cap_h])
                rounded_square_prism(face_w, back_cap_h, corner_r);

            // Front boss
            translate([0,0,body_len])
                cylinder(d=front_boss_d, h=front_boss_h);

            // Shaft
            translate([0,0,body_len+front_boss_h])
                cylinder(d=shaft_d, h=shaft_len);
        }

        // Mounting holes through face and body (along Z)
        for (x = [-mount_spacing/2, mount_spacing/2])
            for (y = [-mount_spacing/2, mount_spacing/2])
                translate([x,y,-back_cap_h-0.5])
                    cylinder(d=mount_hole_d, h=body_len+back_cap_h+front_boss_h+1.0);
    }
}

stepper_motor();