// HT 32 pipe 1000 mm (hollow) with a connected end socket
$fn = 120;

// Dimensions (mm)
outer_diameter = 32;
wall_thickness = 1.8;
length = 1000;

// Simple socket/end fitting (kept modest, but connected)
socket_h = 10;
socket_extra_d = 5;   // socket OD increase over pipe OD
overlap = 1;          // ensures solid connection (no floating)

// Derived
inner_diameter = outer_diameter - 2 * wall_thickness;

module ht_pipe_body() {
    difference() {
        cylinder(h = length, d = outer_diameter);
        translate([0, 0, -0.5])
            cylinder(h = length + 1, d = inner_diameter);
    }
}

module end_socket() {
    // Place so it overlaps the pipe by 'overlap' to guarantee connectivity
    translate([0, 0, length - overlap])
        difference() {
            cylinder(h = socket_h + overlap, d1 = outer_diameter, d2 = outer_diameter + socket_extra_d);
            translate([0, 0, -0.5])
                cylinder(h = socket_h + overlap + 1, d = inner_diameter);
        }
}

union() {
    ht_pipe_body();
    end_socket();
}