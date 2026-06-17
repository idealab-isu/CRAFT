$fn = 96;

// Target dimensions (mm)
face_width     = 39.5;   // square face width
body_length    = 19.2;   // motor body length (depth)
shaft_diameter = 5.0;    // shaft diameter
shaft_length   = 20.0;   // shaft protrusion length
hole_spacing   = 31.0;   // center-to-center spacing
hole_diameter  = 3.0;    // mounting hole diameter (cut)

// Feature proportions (typical stepper look)
front_plate_th = 2.0;
boss_diameter  = 22.0;
boss_height    = 2.0;

corner_chamfer = 3.0;    // small corner cut for recognizability
rear_boss_d    = 16.0;   // rear pilot/boss (common on steppers)
rear_boss_h    = 1.5;

eps = 0.25; // overlap to ensure connectivity

module chamfered_square_prism(w, h, c) {
    // 2D square with 45° corner chamfers, then extruded
    linear_extrude(height=h, center=true)
        polygon(points=[
            [ w/2 - c,  w/2],
            [-w/2 + c,  w/2],
            [-w/2,      w/2 - c],
            [-w/2,     -w/2 + c],
            [-w/2 + c, -w/2],
            [ w/2 - c, -w/2],
            [ w/2,     -w/2 + c],
            [ w/2,      w/2 - c]
        ]);
}

module stepper_motor() {
    union() {
        // Main body centered at origin (so side/front/back views show depth)
        chamfered_square_prism(face_width, body_length, corner_chamfer);

        // Front face plate (slightly proud of body, connected with overlap)
        translate([0, 0, body_length/2 + front_plate_th/2 - eps])
            chamfered_square_prism(face_width, front_plate_th, corner_chamfer);

        // Circular boss on the face (connected)
        translate([0, 0, body_length/2 + front_plate_th + boss_height/2 - eps])
            cylinder(h=boss_height, d=boss_diameter, center=true);

        // Output shaft (connected)
        translate([0, 0, body_length/2 + front_plate_th + boss_height + shaft_length/2 - eps])
            cylinder(h=shaft_length, d=shaft_diameter, center=true);

        // Rear pilot/boss (adds recognizable rear feature; connected)
        translate([0, 0, -body_length/2 - rear_boss_h/2 + eps])
            cylinder(h=rear_boss_h, d=rear_boss_d, center=true);
    }
}

module stepper_motor_with_mount_holes() {
    // Cut real mounting holes through the front plate (and slightly into body)
    difference() {
        stepper_motor();

        hole_h = front_plate_th + 2*eps; // ensure full cut through plate
        z_hole = body_length/2 + front_plate_th/2; // centered in the front plate

        for (x = [-hole_spacing/2, hole_spacing/2])
            for (y = [-hole_spacing/2, hole_spacing/2])
                translate([x, y, z_hole])
                    cylinder(h=hole_h, d=hole_diameter, center=true);
    }
}

stepper_motor_with_mount_holes();