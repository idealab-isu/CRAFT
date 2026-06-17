$fn = 96;

// Parameters (mm)
face_w = 42.3;          // square face width
body_len = 47.0;        // motor body length (excluding shaft)
shaft_d = 5.0;          // shaft diameter
shaft_len = 24.0;       // typical protrusion
mount_spacing = 31.0;   // mounting hole spacing (center-to-center)
mount_hole_d = 3.2;     // typical for M3 clearance
pilot_d = 22.0;         // typical NEMA17 pilot/boss diameter
pilot_h = 2.0;          // boss height
corner_r = 3.0;         // body corner radius (approx)
face_plate_th = 3.0;    // front face plate thickness (approx)
back_cap_th = 2.0;      // rear cap thickness (approx)

// Helpers
module rounded_square_2d(w, r){
    // centered rounded square
    offset(r=r) offset(delta=-r) square([w, w], center=true);
}

module motor_body(){
    // Main body with rounded corners
    linear_extrude(height=body_len)
        rounded_square_2d(face_w, corner_r);
}

module face_plate(){
    // Slightly proud front plate
    linear_extrude(height=face_plate_th)
        rounded_square_2d(face_w, corner_r);
}

module back_cap(){
    // Slightly proud rear cap
    translate([0,0,body_len-back_cap_th])
        linear_extrude(height=back_cap_th)
            rounded_square_2d(face_w, corner_r);
}

module pilot_boss(){
    translate([0,0,0])
        cylinder(d=pilot_d, h=pilot_h);
}

module shaft(){
    translate([0,0,-shaft_len])
        cylinder(d=shaft_d, h=shaft_len + pilot_h);
}

module mount_holes(){
    for (x = [-mount_spacing/2, mount_spacing/2])
        for (y = [-mount_spacing/2, mount_spacing/2])
            translate([x,y,-0.5])
                cylinder(d=mount_hole_d, h=face_plate_th + 1.0);
}

module motor(){
    // Coordinate system:
    // Front face at z=0, body extends to +z, shaft extends to -z
    difference(){
        union(){
            // Body
            motor_body();

            // Front face plate (flush at z=0)
            face_plate();

            // Rear cap
            back_cap();

            // Pilot boss
            pilot_boss();

            // Shaft
            shaft();
        }

        // Mounting holes through front plate
        mount_holes();
    }
}

motor();