// HT 125 pipe 1000 mm (single connected solid)

$fn = 160;

outer_diameter = 125;      // mm
wall_thickness = 3.2;      // mm
length = 1000;             // mm

socket_over_d = 10;        // mm added to OD at socket
socket_len1 = 10;          // mm
socket_len2 = 10;          // mm
overlap = 0.5;             // mm overlap to ensure watertight union/difference

inner_diameter = outer_diameter - 2 * wall_thickness;

module pipe_shell(h, od, id) {
    difference() {
        cylinder(h=h, d=od);
        translate([0, 0, -overlap])
            cylinder(h=h + 2*overlap, d=id);
    }
}

module end_socket() {
    // Socket is an outer enlargement that remains hollow with same wall thickness
    // Positioned so it overlaps the pipe end slightly (no floating parts)
    union() {
        // Larger OD ring
        translate([0, 0, length - overlap])
            pipe_shell(socket_len1 + overlap, outer_diameter + socket_over_d, (outer_diameter + socket_over_d) - 2*wall_thickness);

        // Transition ring back to nominal OD
        translate([0, 0, length + socket_len1 - overlap])
            pipe_shell(socket_len2 + overlap, outer_diameter, inner_diameter);
    }
}

module ht_pipe() {
    union() {
        pipe_shell(length, outer_diameter, inner_diameter);
        end_socket();
    }
}

ht_pipe();