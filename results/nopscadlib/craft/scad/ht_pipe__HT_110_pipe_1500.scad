// Parameters
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 1500; //[750:3000:1]
pipe_wall_mm = 3.2; //[1.6:6.4:0.1]
fitting_length_mm = 60; //[30:120:1]
fitting_radial_thickness_mm = 4; //[2:8:0.5]
connection_overlap_mm = 1; //[0.5:2:0.1]

$fn = 180;

// HT Pipe - one connected solid
module ht_pipe() {
    od_r = nominal_diameter_mm/2;
    id_r = od_r - pipe_wall_mm;

    // Ensure valid geometry
    id_r_safe = max(0.01, id_r);

    body_h = length_mm - fitting_length_mm;
    body_h_safe = max(0.01, body_h);

    // Fitting overlaps into body by connection_overlap_mm
    fit_z = body_h_safe - connection_overlap_mm;

    color([0.85, 0.85, 0.8])
    union() {
        // Main pipe body (hollow)
        difference() {
            cylinder(h=body_h_safe, r=od_r, center=false);
            translate([0, 0, -0.01])
                cylinder(h=body_h_safe + 0.02, r=id_r_safe, center=false);
        }

        // End fitting / socket (hollow), connected via overlap
        translate([0, 0, fit_z])
        difference() {
            cylinder(h=fitting_length_mm, r=od_r + fitting_radial_thickness_mm, center=false);
            translate([0, 0, -0.01])
                cylinder(h=fitting_length_mm + 0.02, r=id_r_safe, center=false);
        }
    }
}

ht_pipe();