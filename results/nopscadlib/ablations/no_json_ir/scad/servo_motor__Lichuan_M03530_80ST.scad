// Servo Motor Model: Lichuan -80M03530B (connected solid, non-blank)

$fn = 96;

// Parameters (mm)
motor_length = 50;
motor_width  = 40;
motor_height = 30;

faceplate_thickness = 5;

shaft_diameter = 6;
shaft_length   = 15;

boss_diameter = 10;
boss_height   = 3;

rear_cap_length = 10;

mounting_hole_diameter = 3;
mounting_hole_offset_y = 5;
mounting_hole_offset_z = 5;

overlap = 0.8; // robust overlap for unions/booleans

// Coordinate system:
// X = length (front faceplate at x=0, body extends +X)
// Y = width
// Z = height
// All main solids are built from x=0..(faceplate+body+rear_cap), y=0..motor_width, z=0..motor_height

module front_faceplate() {
    cube([faceplate_thickness, motor_width, motor_height], center=false);
}

module motor_body() {
    // Body starts after faceplate; overlap slightly into faceplate
    translate([faceplate_thickness - overlap, 0, 0])
        cube([motor_length + overlap, motor_width, motor_height], center=false);
}

module rear_cap() {
    // Rear cap attaches to back of body; overlap slightly into body
    translate([faceplate_thickness + motor_length - overlap, 0, 0])
        cube([rear_cap_length + overlap, motor_width, motor_height], center=false);
}

module shaft_boss() {
    // Boss centered on front faceplate, protruding outward (-X)
    // Use center=false with explicit X range to avoid accidental non-manifold placement
    x0 = -boss_height + overlap; // slightly into faceplate (x=0..)
    translate([x0, motor_width/2, motor_height/2])
        rotate([0,90,0])
            cylinder(h=boss_height, d=boss_diameter, center=false);
}

module output_shaft() {
    // Shaft centered on boss, protruding outward (-X), overlapping into boss
    x0 = -boss_height - shaft_length + overlap; // overlaps into boss by 'overlap'
    translate([x0, motor_width/2, motor_height/2])
        rotate([0,90,0])
            cylinder(h=shaft_length, d=shaft_diameter, center=false);
}

module mounting_holes() {
    // Holes through faceplate along X
    // Make them slightly longer than faceplate to guarantee cut-through
    hole_h = faceplate_thickness + 2*overlap;

    for (y = [mounting_hole_offset_y, motor_width - mounting_hole_offset_y])
        for (z = [mounting_hole_offset_z, motor_height - mounting_hole_offset_z])
            translate([-overlap, y, z])          // start a bit before x=0
                rotate([0,90,0])
                    cylinder(h=hole_h, d=mounting_hole_diameter, center=false);
}

module servo_motor() {
    difference() {
        union() {
            front_faceplate();
            motor_body();
            rear_cap();
            shaft_boss();
            output_shaft();
        }
        mounting_holes();
    }
}

servo_motor();