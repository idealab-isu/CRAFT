// Parameters
nominal_diameter_mm = 160; //[80:320:1]
length_mm = 2000; //[1000:4000:10]
wall_thickness_mm = 4.9; //[2.5:10:0.1]
fitting_length_mm = 70; //[35:140:1]
fitting_radial_increase_mm = 6; //[2:15:0.5]
fitting_stop_ring_length_mm = 12; //[6:30:1]
fitting_stop_ring_radial_increase_mm = 3; //[1:10:0.5]
socket_wall_extra_mm = 1.5; //[0.5:4:0.1]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

// HT Pipe - one connected solid
module ht_pipe() {
    r_outer = nominal_diameter_mm/2;
    r_inner = r_outer - wall_thickness_mm;

    // Socket (outer) radii
    r_socket_outer = r_outer + fitting_radial_increase_mm;
    r_socket_inner = r_inner - socket_wall_extra_mm;

    // Stop ring radius
    r_ring = r_socket_outer + fitting_stop_ring_radial_increase_mm;

    // Clamp to avoid invalid/empty geometry
    r_inner_ok = max(0.01, r_inner);
    r_socket_inner_ok = max(0.01, min(r_socket_inner, r_socket_outer - 0.01));

    // Ensure lengths are valid
    fit_len = min(fitting_length_mm, length_mm);
    ring_len = min(fitting_stop_ring_length_mm, fit_len);

    // Place pipe along X so FRONT/BACK/LEFT/RIGHT orthographic views show the 2000mm length
    rotate([0, 90, 0])
    color([0.85, 0.85, 0.8])
    union() {
        // Main pipe body (hollow)
        difference() {
            cylinder(h=length_mm, r=r_outer, center=false);
            translate([0, 0, -overlap_mm])
                cylinder(h=length_mm + 2*overlap_mm, r=r_inner_ok, center=false);
        }

        // End socket (hollow) connected to main body with overlap
        translate([0, 0, length_mm - fit_len - overlap_mm])
        difference() {
            cylinder(h=fit_len + overlap_mm, r=r_socket_outer, center=false);
            translate([0, 0, -overlap_mm])
                cylinder(h=fit_len + 2*overlap_mm, r=r_socket_inner_ok, center=false);
        }

        // Stop ring (solid) on socket end, overlapping to ensure connectivity
        translate([0, 0, length_mm - ring_len - overlap_mm])
            cylinder(h=ring_len + overlap_mm, r=r_ring, center=false);
    }
}

ht_pipe();