$fn=64;

length = 100;
size = 20;

difference() {
    // Outer body
    cube([size, size, length], center=false);

    // Central bore (typical 2020 extrusion)
    translate([size/2, size/2, -0.1])
        cylinder(h=length+0.2, d=5.2);

    // Slot cutouts on each face (approximation)
    slot_w = 6.2;
    slot_d = 6.0;

    // +X face slot
    translate([size - slot_d, (size-slot_w)/2, -0.1])
        cube([slot_d+0.2, slot_w, length+0.2], center=false);

    // -X face slot
    translate([-0.1, (size-slot_w)/2, -0.1])
        cube([slot_d+0.2, slot_w, length+0.2], center=false);

    // +Y face slot
    translate([(size-slot_w)/2, size - slot_d, -0.1])
        cube([slot_w, slot_d+0.2, length+0.2], center=false);

    // -Y face slot
    translate([(size-slot_w)/2, -0.1, -0.1])
        cube([slot_w, slot_d+0.2, length+0.2], center=false);

    // Corner relief pockets (approximation of internal cavities)
    pocket = 5.5;
    inset = 3.0;

    translate([inset, inset, -0.1])
        cube([pocket, pocket, length+0.2], center=false);

    translate([size-inset-pocket, inset, -0.1])
        cube([pocket, pocket, length+0.2], center=false);

    translate([inset, size-inset-pocket, -0.1])
        cube([pocket, pocket, length+0.2], center=false);

    translate([size-inset-pocket, size-inset-pocket, -0.1])
        cube([pocket, pocket, length+0.2], center=false);
}