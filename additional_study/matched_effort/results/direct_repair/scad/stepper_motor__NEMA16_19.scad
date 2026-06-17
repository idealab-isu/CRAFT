$fn = 96;

// Parameters (mm)
face_w = 39.5;          // motor face width (square)
body_len = 19.2;        // motor body length
shaft_d = 5.0;          // shaft diameter
shaft_len = 20.0;       // assumed shaft protrusion length
mount_spacing = 31.0;   // mounting hole center-to-center spacing
mount_hole_d = 3.2;     // typical for M3 clearance (assumed)
front_plate_th = 2.0;   // assumed front plate thickness
pilot_d = 22.0;         // typical NEMA pilot diameter (assumed)
pilot_h = 1.8;          // assumed pilot height

module stepper_motor(
    face_w=39.5,
    body_len=19.2,
    shaft_d=5.0,
    shaft_len=20.0,
    mount_spacing=31.0,
    mount_hole_d=3.2,
    front_plate_th=2.0,
    pilot_d=22.0,
    pilot_h=1.8
){
    difference() {
        union() {
            // Main body
            translate([-face_w/2, -face_w/2, 0])
                cube([face_w, face_w, body_len], center=false);

            // Front plate (slight lip)
            translate([-face_w/2, -face_w/2, body_len])
                cube([face_w, face_w, front_plate_th], center=false);

            // Pilot boss
            translate([0, 0, body_len + front_plate_th])
                cylinder(d=pilot_d, h=pilot_h);

            // Shaft
            translate([0, 0, body_len + front_plate_th + pilot_h])
                cylinder(d=shaft_d, h=shaft_len);
        }

        // Mounting holes through front plate (and slightly into body)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*mount_spacing/2, sy*mount_spacing/2, body_len - 0.5])
                cylinder(d=mount_hole_d, h=front_plate_th + 1.0);
        }
    }
}

stepper_motor(
    face_w=face_w,
    body_len=body_len,
    shaft_d=shaft_d,
    shaft_len=shaft_len,
    mount_spacing=mount_spacing,
    mount_hole_d=mount_hole_d,
    front_plate_th=front_plate_th,
    pilot_d=pilot_d,
    pilot_h=pilot_h
);