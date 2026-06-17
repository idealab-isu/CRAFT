$fn = 96;

// Parameters (mm)
face_w = 39.5;          // square face width
body_len = 19.2;        // motor body length (excluding front boss/shaft)
shaft_d = 5.0;          // shaft diameter
shaft_len = 20.0;       // visible shaft length
mount_spacing = 31.0;   // mounting hole center-to-center spacing
mount_hole_d = 3.2;     // typical M3 clearance
front_boss_d = 22.0;    // typical NEMA-style pilot/boss
front_boss_h = 2.0;     // boss height
corner_r = 3.0;         // body corner radius

module rounded_square_prism(w, h, r){
    linear_extrude(height=h)
        offset(r=r)
            square([w-2*r, w-2*r], center=true);
}

module stepper_motor(){
    // Body with mounting holes through
    difference(){
        // Main body
        translate([0,0,-body_len])
            rounded_square_prism(face_w, body_len, corner_r);

        // Mounting holes (through body)
        for (x = [-mount_spacing/2, mount_spacing/2])
            for (y = [-mount_spacing/2, mount_spacing/2])
                translate([x,y,-body_len-0.5])
                    cylinder(d=mount_hole_d, h=body_len+1.0);
    }

    // Front boss
    cylinder(d=front_boss_d, h=front_boss_h);

    // Shaft
    translate([0,0,front_boss_h])
        cylinder(d=shaft_d, h=shaft_len);
}

stepper_motor();