// HT 110 pipe 1000 mm (single connected solid)

// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 1000; //[500:2000:1]
include_end_fitting = 1; //[0:1:1]
pipe_od_mm = 110; //[55:220:1]
pipe_wall_mm = 3.2; //[1.6:6.4:0.1]
fit_socket_length_mm = 60; //[30:120:1]
fit_socket_wall_extra_mm = 2.0; //[1.0:5.0:0.1]
fit_stop_ring_length_mm = 8; //[4:20:1]
fit_stop_ring_radial_extra_mm = 2.0; //[1.0:6.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

$fn = 128;

module ht_pipe() {
    od_r = pipe_od_mm/2;
    id_r = max(0.01, od_r - pipe_wall_mm);

    socket_od_r = od_r + fit_socket_wall_extra_mm;
    ring_od_r   = socket_od_r + fit_stop_ring_radial_extra_mm;

    // Keep everything centered around Z=0 so it is always visible in default view
    // Main pipe spans: [-length/2, +length/2]
    // Socket is on the +Z end, overlapping into the main pipe by overlap_mm
    socket_z0 = (length_mm/2) - overlap_mm;
    ring_z0   = socket_z0 + fit_socket_length_mm - fit_stop_ring_length_mm - overlap_mm;

    // Inner bore should be continuous through pipe + socket
    inner_h = length_mm + (include_end_fitting ? fit_socket_length_mm : 0);

    color([0.85, 0.85, 0.8])
    difference() {
        union() {
            // Main outer pipe (centered)
            cylinder(h=length_mm, r=od_r, center=true);

            if (include_end_fitting) {
                // Outer socket (connected via overlap)
                translate([0, 0, socket_z0 + fit_socket_length_mm/2])
                    cylinder(h=fit_socket_length_mm, r=socket_od_r, center=true);

                // Stop ring (connected via overlap)
                translate([0, 0, ring_z0 + fit_stop_ring_length_mm/2])
                    cylinder(h=fit_stop_ring_length_mm, r=ring_od_r, center=true);
            }
        }

        // Inner void (centered), extended slightly to avoid coplanar artifacts
        cylinder(h=inner_h + 0.4, r=id_r, center=true);
    }
}

ht_pipe();