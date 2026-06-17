// HT 160 pipe 500 mm (one connected solid)
nominal_diameter = 160; //[80:320:1]
length_mm = 500; //[250:1000:1]
ht160_outer_diameter = 160; //[120:200:1]
wall_thickness = 4.7; //[2.5:9.5:0.1]
socket_length = 70; //[40:120:1]
socket_wall_extra = 3.0; //[1.0:8.0:0.1]
socket_clearance = 1.0; //[0.2:2.5:0.1]
stop_ring_thickness = 3.0; //[1.0:8.0:0.1]
stop_ring_offset_from_end = 18; //[8:35:1]
stop_ring_radial_reduction = 2.0; //[0.5:5.0:0.1]
connection_overlap = 1.0; //[0.5:2.0:0.1]

$fn = 128;

module ht_pipe() {
    outer_r = ht160_outer_diameter/2;
    inner_r = max(0.01, outer_r - wall_thickness);

    socket_outer_r = outer_r + socket_wall_extra;
    socket_inner_r = outer_r + socket_clearance;

    body_h = length_mm;

    // Place body so its -Z end is at 0, +Z end at body_h
    body_zc = body_h/2;

    // Socket attached to +Z end of body with overlap
    socket_zc = body_h + socket_length/2 - connection_overlap;

    // Stop ring position measured from socket outer end (+Z end of socket)
    socket_end_z = body_h + socket_length - connection_overlap;
    ring_zc = socket_end_z - stop_ring_offset_from_end - stop_ring_thickness/2;

    // Ring creates an internal shoulder by reducing the inner void locally
    ring_void_r = max(0.01, socket_inner_r - stop_ring_radial_reduction);

    // Small epsilon to avoid coplanar faces
    eps = 0.2;

    color([0.85, 0.85, 0.8])
    difference() {
        // OUTER SOLID (connected)
        union() {
            translate([0, 0, body_zc])
                cylinder(h=body_h, r=outer_r, center=true);

            translate([0, 0, socket_zc])
                cylinder(h=socket_length, r=socket_outer_r, center=true);
        }

        // INNER VOIDS (connected)
        union() {
            // Main bore: extend slightly beyond ends
            translate([0, 0, body_zc])
                cylinder(h=body_h + 2*(connection_overlap + eps), r=inner_r, center=true);

            // Socket bore: extend slightly beyond ends
            translate([0, 0, socket_zc])
                cylinder(h=socket_length + 2*(connection_overlap + eps), r=socket_inner_r, center=true);

            // Stop ring: remove a smaller-bore section to leave a shoulder
            translate([0, 0, ring_zc])
                cylinder(h=stop_ring_thickness + 2*eps, r=ring_void_r, center=true);
        }
    }
}

ht_pipe();