$fn=96;

// Parameters (mm)
face_w = 42.3;          // motor face width (square)
body_len = 40.0;        // motor body length (excluding front boss/shaft)
shaft_d = 8.0;          // shaft diameter
mount_spacing = 31.0;   // mounting hole spacing (center-to-center)
mount_hole_d = 3.4;     // typical NEMA17 clearance for M3
front_boss_d = 22.0;    // typical pilot/boss diameter
front_boss_h = 2.0;     // typical boss height
shaft_len = 20.0;       // visible shaft length
corner_r = 3.0;         // slight corner rounding

module rounded_square_prism(w, h, r){
    // centered at origin, extruded along +Z from 0..h
    linear_extrude(height=h)
        offset(r=r)
            offset(delta=-r)
                square([w, w], center=true);
}

module motor_body(){
    difference(){
        // Main body
        rounded_square_prism(face_w, body_len, corner_r);

        // Mounting holes through front face into body
        for (x = [-mount_spacing/2, mount_spacing/2])
            for (y = [-mount_spacing/2, mount_spacing/2])
                translate([x, y, -0.1])
                    cylinder(d=mount_hole_d, h=body_len+0.2);
    }

    // Front boss (pilot)
    translate([0,0,0])
        cylinder(d=front_boss_d, h=front_boss_h);

    // Shaft
    translate([0,0,front_boss_h])
        cylinder(d=shaft_d, h=shaft_len);
}

// Render with front face at Z=0, body extending +Z
motor_body();