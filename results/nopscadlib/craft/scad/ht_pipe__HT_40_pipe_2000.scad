$fn = 128;

// Parameters
nominal_diameter = 40; //[20:80:1]
length_mm = 2000; //[1000:4000:10]
pipe_wall_thickness = 2.0; //[1.0:4.0:0.1]
end_fitting_length = 35; //[15:70:1]
end_fitting_wall_extra = 1.5; //[0.5:4.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

module ht_pipe() {
    od = nominal_diameter;
    r_outer = od/2;
    r_inner = max(0.01, r_outer - pipe_wall_thickness);

    r_socket_outer = r_outer + end_fitting_wall_extra;
    r_socket_inner = r_inner;

    // Build centered on Z for predictable viewing
    main_z0 = -length_mm/2;
    socket_z0 = length_mm/2 - overlap; // ensures connection with overlap

    color([0.85, 0.85, 0.8])
    union() {
        // Main pipe (hollow)
        translate([0, 0, main_z0])
        difference() {
            cylinder(r=r_outer, h=length_mm, center=false);
            translate([0, 0, -overlap])
                cylinder(r=r_inner, h=length_mm + 2*overlap, center=false);
        }

        // End socket/fitting at +Z end (connected)
        translate([0, 0, socket_z0])
        difference() {
            cylinder(r=r_socket_outer, h=end_fitting_length, center=false);
            translate([0, 0, -overlap])
                cylinder(r=r_socket_inner, h=end_fitting_length + 2*overlap, center=false);
        }
    }
}

ht_pipe();