$fn = 128;

// Brushless DC motor (approximate) with 42.5mm stator diameter and 48.0mm height
// Units: mm

stator_d = 42.5;
motor_h  = 48.0;

// Simple outer can + endbells + shaft + mounting face details (generic)
can_wall = 1.2;
endbell_h = 6.0;
shaft_d = 5.0;
shaft_len_front = 18.0;
shaft_len_back  = 6.0;

front_face_boss_d = 18.0;
front_face_boss_h = 1.5;

mount_hole_circle_d = 25.0;
mount_hole_d = 3.0;
mount_hole_depth = 4.0;

wire_exit_w = 8.0;
wire_exit_h = 4.0;
wire_exit_len = 10.0;

module motor_can() {
    // Outer can
    difference() {
        cylinder(d = stator_d, h = motor_h);
        translate([0,0, endbell_h])
            cylinder(d = stator_d - 2*can_wall, h = motor_h - 2*endbell_h);
    }
}

module endbell_front() {
    // Front endbell lip + boss
    union() {
        cylinder(d = stator_d, h = endbell_h);
        translate([0,0,endbell_h])
            cylinder(d = front_face_boss_d, h = front_face_boss_h);
    }
}

module endbell_back() {
    // Back endbell with wire exit notch
    difference() {
        cylinder(d = stator_d, h = endbell_h);
        // wire exit notch
        translate([stator_d/2 - 1.0, 0, endbell_h/2])
            rotate([0,90,0])
                cube([wire_exit_len, wire_exit_w, wire_exit_h], center=true);
    }
}

module mounting_holes_front() {
    // 4 mounting holes on a circle, shallow
    for (a = [0:90:270]) {
        rotate([0,0,a])
            translate([mount_hole_circle_d/2, 0, endbell_h + front_face_boss_h - mount_hole_depth])
                cylinder(d = mount_hole_d, h = mount_hole_depth + 0.2);
    }
}

module shaft() {
    // Shaft through motor, protruding front and slightly back
    translate([0,0,-shaft_len_back])
        cylinder(d = shaft_d, h = motor_h + shaft_len_front + shaft_len_back);
}

module motor() {
    difference() {
        union() {
            // Back endbell at z=0
            endbell_back();

            // Can body middle
            translate([0,0,endbell_h])
                difference() {
                    cylinder(d = stator_d, h = motor_h - 2*endbell_h);
                    // slight internal cavity (already in motor_can, but keep simple here)
                }

            // Front endbell at top
            translate([0,0,motor_h - endbell_h])
                endbell_front();

            // Shaft
            shaft();
        }

        // Front mounting holes
        mounting_holes_front();

        // Small chamfer-like relief on front edge (approx)
        translate([0,0,motor_h - 0.8])
            cylinder(d1 = stator_d, d2 = stator_d - 1.2, h = 0.8);

        // Small chamfer-like relief on back edge (approx)
        translate([0,0,0])
            cylinder(d1 = stator_d - 1.2, d2 = stator_d, h = 0.8);
    }
}

motor();