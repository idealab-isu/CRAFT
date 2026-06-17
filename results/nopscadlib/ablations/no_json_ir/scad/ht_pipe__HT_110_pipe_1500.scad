// HT 110 pipe 1500 mm (single connected solid)

// Dimensions (mm)
outer_diameter = 110;
wall_thickness = 3.2;
length = 1500;

// Simple socket/bell end (kept connected with overlap)
socket_len = 60;
socket_extra_d = 10;   // socket OD increase vs pipe OD
socket_wall_extra = 1; // socket wall slightly thicker than pipe wall

$fn = 160;

module ht_pipe() {
    od = outer_diameter;
    id = od - 2*wall_thickness;

    socket_od = od + socket_extra_d;
    socket_id = socket_od - 2*(wall_thickness + socket_wall_extra);

    overlap = 1; // ensures union connectivity

    union() {
        // Main pipe (hollow)
        difference() {
            cylinder(h=length, d=od, center=false);
            translate([0, 0, -overlap])
                cylinder(h=length + 2*overlap, d=id, center=false);
        }

        // Socket end (hollow), overlapping into pipe so it's one connected solid
        translate([0, 0, length - overlap])
        difference() {
            cylinder(h=socket_len + overlap, d=socket_od, center=false);
            translate([0, 0, -overlap])
                cylinder(h=socket_len + 3*overlap, d=socket_id, center=false);
        }
    }
}

ht_pipe();