// HT 110 pipe, length 250 mm (single connected solid)

// Parameters
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 250; //[125:500:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
fitting_length_mm = 35; //[18:70:1]
fitting_radial_increase_mm = 4; //[2:10:0.5]
fitting_wall_extra_mm = 1.2; //[0.6:3:0.1]
fitting_stop_ring_length_mm = 6; //[3:15:0.5]
fitting_stop_ring_radial_mm = 2; //[1:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

module ht_pipe() {
    r_outer = nominal_diameter_mm/2;
    r_inner = r_outer - wall_thickness_mm;

    // Sleeve (socket) radii
    r_sleeve_outer = r_outer + fitting_radial_increase_mm;
    r_sleeve_inner = r_outer - (wall_thickness_mm + fitting_wall_extra_mm);

    // Stop ring radius
    r_ring_outer = r_sleeve_outer + fitting_stop_ring_radial_mm;

    // Axial placement: socket at z=0 end (matches reference views)
    z_pipe0   = 0;
    z_pipe1   = length_mm;

    z_sleeve0 = z_pipe0;
    z_sleeve1 = z_pipe0 + fitting_length_mm;

    z_ring0   = z_pipe0;
    z_ring1   = z_pipe0 + fitting_stop_ring_length_mm;

    // Validations
    assert(length_mm > 0, "length_mm must be > 0");
    assert(wall_thickness_mm > 0, "wall_thickness_mm must be > 0");
    assert(r_inner > 0, "wall_thickness_mm too large for nominal_diameter_mm");
    assert(r_sleeve_inner > 0, "fitting_wall_extra_mm too large");
    assert(r_sleeve_inner < r_sleeve_outer, "Sleeve inner radius must be smaller than sleeve outer radius");
    assert(fitting_length_mm >= fitting_stop_ring_length_mm, "Stop ring length must be <= fitting length");

    color([0.85, 0.85, 0.8])
    difference() {
        // OUTER SOLID (connected via overlaps)
        union() {
            // Main outer cylinder
            cylinder(r=r_outer, h=length_mm, center=false);

            // End fitting sleeve at z=0 end, overlapping into main
            translate([0, 0, z_sleeve0 - overlap_mm])
                cylinder(r=r_sleeve_outer, h=fitting_length_mm + overlap_mm, center=false);

            // Stop ring at very end, overlapping into sleeve
            translate([0, 0, z_ring0 - overlap_mm])
                cylinder(r=r_ring_outer, h=fitting_stop_ring_length_mm + overlap_mm, center=false);
        }

        // INNER VOID (single connected cavity)
        union() {
            // Main pipe bore (extended for clean subtraction)
            translate([0, 0, z_pipe0 - 2*overlap_mm])
                cylinder(r=r_inner, h=length_mm + 4*overlap_mm, center=false);

            // Sleeve bore (slightly larger, opens at z=0 end)
            translate([0, 0, z_sleeve0 - 2*overlap_mm])
                cylinder(r=r_sleeve_inner, h=fitting_length_mm + 4*overlap_mm, center=false);
        }
    }
}

ht_pipe();