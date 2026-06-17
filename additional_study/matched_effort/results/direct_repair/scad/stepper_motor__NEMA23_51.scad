$fn = 96;

// Parameters (mm)
face_w = 56.4;          // square face width
body_len = 51.2;        // motor body length (excluding shaft)
shaft_d = 6.35;         // shaft diameter
shaft_len = 20;         // assumed visible shaft length
mount_spacing = 47.1;   // mounting hole center-to-center spacing
mount_hole_d = 5.0;     // typical NEMA mounting hole diameter (assumed)
pilot_d = 22.0;         // typical front pilot diameter (assumed)
pilot_h = 2.0;          // pilot height (assumed)
front_plate_th = 3.0;   // front plate thickness (assumed)
corner_r = 3.0;         // body corner radius (assumed)
back_boss_d = 38.0;     // rear boss diameter (assumed)
back_boss_h = 2.0;      // rear boss height (assumed)

module rounded_square_prism(w, h, r){
    linear_extrude(height=h)
        offset(r=r)
            square([w-2*r, w-2*r], center=true);
}

module stepper_motor(){
    // Body with rounded corners
    color([0.25,0.25,0.25])
    difference(){
        union(){
            // main body
            translate([0,0,0])
                rounded_square_prism(face_w, body_len, corner_r);

            // front plate (slightly proud)
            translate([0,0,body_len - front_plate_th])
                rounded_square_prism(face_w, front_plate_th, corner_r);

            // rear boss
            translate([0,0,0])
                cylinder(d=back_boss_d, h=back_boss_h);

            // front pilot
            translate([0,0,body_len])
                cylinder(d=pilot_d, h=pilot_h);
        }

        // Mounting holes through front plate region
        for (sx = [-1,1], sy = [-1,1]){
            translate([sx*mount_spacing/2, sy*mount_spacing/2, body_len - front_plate_th - 0.5])
                cylinder(d=mount_hole_d, h=front_plate_th + pilot_h + 2.0);
        }
    }

    // Shaft
    color([0.75,0.75,0.78])
    translate([0,0,body_len + pilot_h])
        cylinder(d=shaft_d, h=shaft_len);

    // Small shaft flat (approximation)
    flat_depth = 0.8;
    flat_len = shaft_len * 0.65;
    translate([0,0,body_len + pilot_h])
    difference(){
        cylinder(d=shaft_d, h=flat_len);
        translate([shaft_d/2 - flat_depth, -shaft_d, -1])
            cube([shaft_d, 2*shaft_d, flat_len+2], center=false);
    }
}

stepper_motor();