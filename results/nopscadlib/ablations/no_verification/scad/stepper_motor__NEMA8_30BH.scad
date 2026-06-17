$fn = 96;

// Target dimensions
face_width = 20.0;          // square face width (X,Y)
body_length = 30.0;         // body length (Z, behind face)
face_thickness = 2.0;       // front plate thickness (Z, in front of body)

shaft_diameter = 5.0;       // shaft diameter
shaft_length = 10.0;        // shaft protrusion from front face

mount_hole_spacing = 16.0;  // center-to-center spacing (square pattern)
mount_hole_diameter = 3.0;  // visual hole diameter (not subtracted)

overlap = 0.8;              // overlap to guarantee connectivity

// Derived Z references (front face centered at Z=0)
z_face_center = 0;
z_front_surface = face_thickness/2;
z_body_center = -(face_thickness/2 + body_length/2 - overlap);
z_body_back_surface = z_body_center - body_length/2;

// One connected solid with visible face details and mounting pattern
module stepper_motor() {
    union() {
        // Body block (behind face)
        translate([0, 0, z_body_center])
            cube([face_width, face_width, body_length], center=true);

        // Front face plate
        translate([0, 0, z_face_center])
            cube([face_width, face_width, face_thickness], center=true);

        // Front boss (make it clearly visible in orthographic views)
        boss_d = max(shaft_diameter + 8, 12);  // ensure visible ring around shaft
        boss_h = 2.5;
        translate([0, 0, z_front_surface + boss_h/2 - overlap])
            cylinder(d=boss_d, h=boss_h, center=true);

        // Shaft (connected to boss/face)
        translate([0, 0, z_front_surface + shaft_length/2 - overlap])
            cylinder(d=shaft_diameter, h=shaft_length, center=true);

        // Mounting hole markers as raised pads (visible in front/back/left/right)
        // Use larger pads than the hole diameter so they read clearly in silhouette.
        pad_d = max(mount_hole_diameter, 4.2);
        pad_h = 1.2;
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*mount_hole_spacing/2, sy*mount_hole_spacing/2,
                       z_front_surface + pad_h/2 - overlap])
                cylinder(d=pad_d, h=pad_h, center=true);
        }

        // Subtle face rim to add front detail without changing face width
        rim_inset = 1.2;
        rim_h = 0.8;
        translate([0, 0, z_front_surface + rim_h/2 - overlap])
            difference() {
                cube([face_width, face_width, rim_h], center=true);
                cube([face_width - 2*rim_inset, face_width - 2*rim_inset, rim_h + 2*overlap], center=true);
            }

        // Rear connector bump (connected to back face)
        conn_w = 8;
        conn_h = 6;
        conn_t = 4;
        translate([0, 0, z_body_back_surface - conn_t/2 + overlap])
            cube([conn_w, conn_h, conn_t], center=true);
    }
}

stepper_motor();