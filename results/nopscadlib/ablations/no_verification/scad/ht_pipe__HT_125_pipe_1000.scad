// HT 125 pipe 1000 mm (socketed end) - one connected solid

// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 125; //[63:250:1]
length_mm = 1000; //[500:2000:10]
pipe_od_mm = 125; //[63:250:1]
pipe_wall_mm = 3.2; //[1.6:6.4:0.1]
fitting_length_mm = 60; //[30:120:1]
fitting_wall_extra_mm = 2.0; //[0.5:6.0:0.1]
fitting_stop_thickness_mm = 4; //[2:10:1]
fitting_stop_depth_mm = 20; //[10:60:1]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

module ht_pipe() {
    pipe_r   = pipe_od_mm/2;
    bore_r   = pipe_r - pipe_wall_mm;
    fitting_r = pipe_r + fitting_wall_extra_mm;

    // Z layout (pipe runs from z=0..length_mm, socket extends to negative Z)
    z_pipe0 = 0;
    z_pipe1 = length_mm;

    z_fit0  = -fitting_length_mm;
    z_fit1  = 0;

    // Stop ring location inside socket
    z_stop0 = z_fit0 + fitting_stop_depth_mm;
    z_stop1 = z_stop0 + fitting_stop_thickness_mm;

    // Safety: ensure valid radii
    assert(bore_r > 0, "pipe_wall_mm too large: bore radius <= 0");
    assert(fitting_stop_depth_mm + fitting_stop_thickness_mm <= fitting_length_mm,
           "Stop ring exceeds socket length");

    color([0.85, 0.85, 0.8])
    difference() {
        // OUTER SOLID (connected union)
        union() {
            // Main pipe outer
            translate([0,0,z_pipe0])
                cylinder(h=length_mm, r=pipe_r, center=false);

            // Socket outer (overlap into pipe to guarantee connectivity)
            translate([0,0,z_fit0])
                cylinder(h=fitting_length_mm + overlap_mm, r=fitting_r, center=false);

            // Stop ring material (adds internal shoulder)
            translate([0,0,z_stop0])
                cylinder(h=fitting_stop_thickness_mm, r=pipe_r, center=false);
        }

        // INNER VOID (continuous)
        union() {
            // Through-bore (extend beyond ends to avoid coplanar faces)
            translate([0,0,z_fit0 - overlap_mm])
                cylinder(h=(length_mm + fitting_length_mm) + 2*overlap_mm, r=bore_r, center=false);

            // Socket cavity (female end) up to the stop ring
            translate([0,0,z_fit0 - overlap_mm])
                cylinder(h=fitting_stop_depth_mm + overlap_mm, r=pipe_r, center=false);
        }
    }
}

ht_pipe();