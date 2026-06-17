$fn=128;

// Brushless DC motor (simplified) with 23mm stator diameter and 12mm stator height
stator_d = 23.0;
stator_h = 12.0;

// Simple motor proportions (approximate, derived from stator size)
can_wall = 0.8;
can_d = stator_d + 2*can_wall;          // outer can diameter
can_h = stator_h + 4.0;                 // can slightly taller than stator

endcap_h = 1.2;
base_flange_h = 1.0;

shaft_d = 3.0;
shaft_len_front = 10.0;
shaft_len_back  = 2.0;

mount_bolt_circle_d = 16.0;
mount_hole_d = 2.0;
mount_hole_depth = 3.0;

wire_exit_w = 5.0;
wire_exit_h = 2.5;
wire_exit_len = 6.0;

module motor_can() {
    // Outer can with inner cavity
    difference() {
        union() {
            // main can
            cylinder(d=can_d, h=can_h);
            // base flange (slight)
            translate([0,0,-base_flange_h])
                cylinder(d=can_d+1.2, h=base_flange_h);
            // front endcap lip
            translate([0,0,can_h])
                cylinder(d=can_d-0.6, h=endcap_h);
        }
        // inner cavity
        translate([0,0,0.8])
            cylinder(d=can_d-2*can_wall, h=can_h+endcap_h);
        
        // wire exit notch on side near base
        translate([can_d/2 - 0.2, 0, 2.0])
            rotate([0,90,0])
                cube([wire_exit_len, wire_exit_w, wire_exit_h], center=true);
    }
}

module stator() {
    // Stator ring (simplified)
    stator_id = stator_d * 0.55;
    difference() {
        translate([0,0,1.5])
            cylinder(d=stator_d, h=stator_h);
        translate([0,0,1.5-0.01])
            cylinder(d=stator_id, h=stator_h+0.02);
    }
}

module rotor() {
    // Rotor sleeve inside stator (simplified)
    rotor_d = stator_d * 0.52;
    rotor_h = stator_h - 1.0;
    translate([0,0,2.0])
        cylinder(d=rotor_d, h=rotor_h);
}

module shaft() {
    // Shaft through motor
    translate([0,0,can_h + endcap_h])
        cylinder(d=shaft_d, h=shaft_len_front);
    translate([0,0,-shaft_len_back - base_flange_h])
        cylinder(d=shaft_d, h=shaft_len_back + base_flange_h);
}

module mounting_holes() {
    // Four mounting holes on base face
    for (a = [0:90:270]) {
        translate([mount_bolt_circle_d/2*cos(a), mount_bolt_circle_d/2*sin(a), -base_flange_h-0.01])
            cylinder(d=mount_hole_d, h=mount_hole_depth + 0.02);
    }
}

module motor() {
    difference() {
        union() {
            color([0.25,0.25,0.27]) motor_can();
            color([0.55,0.55,0.58]) stator();
            color([0.35,0.35,0.38]) rotor();
            color([0.75,0.75,0.78]) shaft();
        }
        mounting_holes();
    }
}

motor();