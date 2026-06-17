// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 75; //[40:150:1]
length_mm = 1500; //[750:3000:10]
wall_thickness_mm = 2.7; //[1.5:6:0.1]
fitting_length_mm = 60; //[30:120:1]
fitting_wall_extra_mm = 2.0; //[0.5:6:0.1]
connection_overlap_mm = 1.0; //[0.5:2.0:0.1]

$fn = 128;

// HT Pipe - one connected solid (pipe + socket)
module ht_pipe() {
    outer_r = nominal_diameter_mm/2;
    inner_r = outer_r - wall_thickness_mm;
    socket_outer_r = outer_r + fitting_wall_extra_mm;

    // Ensure valid geometry
    inner_r_ok = max(0.01, inner_r);

    // Z placement so socket overlaps the main pipe by connection_overlap_mm
    // Main pipe spans: [-length/2, +length/2]
    // Socket spans: [socket_center - fitting/2, socket_center + fitting/2]
    // Set socket_start = length/2 - overlap
    socket_center_z = (length_mm/2 - connection_overlap_mm) + fitting_length_mm/2;

    color([0.85, 0.85, 0.8])
    difference() {
        // OUTER: union of main OD + socket OD (connected via overlap)
        union() {
            cylinder(h=length_mm, r=outer_r, center=true);
            translate([0, 0, socket_center_z])
                cylinder(h=fitting_length_mm, r=socket_outer_r, center=true);
        }

        // INNER: continuous bore through entire part (extends beyond to guarantee clean subtraction)
        cylinder(h=length_mm + fitting_length_mm + 2, r=inner_r_ok, center=true);
    }
}

// Assembly
module assembly() {
    ht_pipe();
}

assembly();