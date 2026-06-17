$fn = 96;

face_w = 20.0;          // square face width
body_len = 30.0;        // motor body length (excluding shaft)
shaft_d = 4.0;          // shaft diameter
shaft_len = 18.0;       // visible shaft length
mount_spacing = 16.0;   // center-to-center spacing of mounting holes
mount_hole_d = 3.0;     // typical M3 clearance
front_plate_th = 2.0;   // front face plate thickness
boss_d = 10.0;          // front boss diameter
boss_th = 2.0;          // boss thickness

edge_r = 1.2;           // slight edge rounding approximation
body_w = face_w;
body_h = face_w;

module rounded_box(size=[20,20,30], r=1.2){
    // Minkowski rounding (kept small for performance)
    minkowski(){
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
        sphere(r=r);
    }
}

module stepper_motor(){
    // Coordinate system:
    // Z axis is motor axis; front face at z=0, body extends to negative Z, shaft to positive Z.
    difference(){
        union(){
            // Body
            translate([0,0,-body_len/2])
                rounded_box([body_w, body_h, body_len], r=edge_r);

            // Front plate
            translate([0,0,-front_plate_th/2])
                cube([face_w, face_w, front_plate_th], center=true);

            // Front boss
            translate([0,0,boss_th/2])
                cylinder(d=boss_d, h=boss_th, center=true);

            // Shaft
            translate([0,0,boss_th + shaft_len/2])
                cylinder(d=shaft_d, h=shaft_len, center=true);
        }

        // Mounting holes through front plate (and slightly into body)
        for (x = [-mount_spacing/2, mount_spacing/2])
            for (y = [-mount_spacing/2, mount_spacing/2])
                translate([x,y,-front_plate_th/2 - 1])
                    cylinder(d=mount_hole_d, h=front_plate_th + 4, center=true);
    }
}

stepper_motor();