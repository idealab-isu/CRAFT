$fn=128;

// Brushless DC motor (simplified) with 9.0mm stator diameter and 8.0mm height
stator_d = 9.0;
stator_h = 8.0;

// Simple motor proportions (approximate)
can_wall = 0.6;
can_d = stator_d + 2*can_wall;     // outer can diameter
can_h = stator_h + 1.0;            // slightly taller than stator
endcap_h = 0.8;

shaft_d = 1.5;
shaft_len_front = 6.0;
shaft_len_back  = 1.5;

mount_ring_d = can_d + 1.2;
mount_ring_h = 0.8;

wire_d = 0.8;
wire_len = 10.0;

module motor_can() {
    difference() {
        cylinder(d=can_d, h=can_h);
        translate([0,0,endcap_h])
            cylinder(d=stator_d+0.4, h=can_h-2*endcap_h);
    }
}

module stator() {
    // Stator core
    color([0.35,0.35,0.35])
    translate([0,0,(can_h-stator_h)/2])
        cylinder(d=stator_d, h=stator_h);
}

module endcaps() {
    color([0.75,0.75,0.75]) {
        cylinder(d=can_d, h=endcap_h);
        translate([0,0,can_h-endcap_h])
            cylinder(d=can_d, h=endcap_h);
    }
}

module shaft() {
    color([0.85,0.85,0.9]) {
        // Front shaft
        translate([0,0,can_h])
            cylinder(d=shaft_d, h=shaft_len_front);
        // Back stub
        translate([0,0,-shaft_len_back])
            cylinder(d=shaft_d, h=shaft_len_back);
    }
}

module mount_ring() {
    // Small mounting ring at front
    color([0.6,0.6,0.6])
    translate([0,0,can_h-endcap_h-mount_ring_h])
        difference() {
            cylinder(d=mount_ring_d, h=mount_ring_h);
            cylinder(d=can_d-0.2, h=mount_ring_h+0.02);
        }
}

module wires() {
    // Three wires exiting from side near back
    color([0.9,0.2,0.2])
    translate([can_d/2, 0, endcap_h*0.6])
        rotate([0,90,0]) cylinder(d=wire_d, h=wire_len);
    color([0.2,0.9,0.2])
    translate([can_d/2, 1.2, endcap_h*0.6])
        rotate([0,90,0]) cylinder(d=wire_d, h=wire_len);
    color([0.2,0.2,0.9])
    translate([can_d/2, -1.2, endcap_h*0.6])
        rotate([0,90,0]) cylinder(d=wire_d, h=wire_len);
}

module motor() {
    // Outer can
    color([0.15,0.15,0.15]) motor_can();
    endcaps();
    stator();
    mount_ring();
    shaft();
    wires();
}

motor();