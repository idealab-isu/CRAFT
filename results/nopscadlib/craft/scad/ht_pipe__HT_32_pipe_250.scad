// HT 32 pipe 250 mm (single connected solid)

// Parameters
nominal_diameter_mm = 32; //[16:64:1]
length_mm = 250; //[125:500:1]
od_mm = 32; //[16:64:0.1]
wall_mm = 2.4; //[1.2:4.8:0.1]
fitting_length_mm = 35; //[18:70:1]
fitting_wall_extra_mm = 2.0; //[1.0:6.0:0.1]
fitting_socket_clearance_mm = 0.4; //[0.1:1.0:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]

$fn = 128;

module ht_pipe() {
    // Derived radii
    r_od = od_mm/2;
    r_id = r_od - wall_mm;

    r_fit_od = r_od + fitting_wall_extra_mm;
    r_fit_id = r_od + fitting_socket_clearance_mm;

    // Safety clamps
    r_id_ok = max(0.01, r_id);
    r_fit_id_ok = max(0.01, r_fit_id);

    // Ensure overlap and valid socket placement
    overlap_ok = max(0.01, overlap_mm);
    fit_len_ok = max(0.01, fitting_length_mm);
    fit_z0 = max(0, length_mm - fit_len_ok - overlap_ok);

    // Small epsilon to avoid coplanar/empty boolean artifacts
    eps = 0.02;

    color([0.85, 0.85, 0.8])
    difference() {
        // ONE connected outer solid (pipe + socket sleeve)
        union() {
            cylinder(h=length_mm, r=r_od, center=false);
            translate([0, 0, fit_z0])
                cylinder(h=fit_len_ok, r=r_fit_od, center=false);
        }

        // Inner voids (slightly extended to guarantee open ends)
        translate([0, 0, -eps])
            cylinder(h=length_mm + 2*eps, r=r_id_ok, center=false);

        translate([0, 0, fit_z0 - eps])
            cylinder(h=fit_len_ok + 2*eps, r=r_fit_id_ok, center=false);
    }
}

ht_pipe();