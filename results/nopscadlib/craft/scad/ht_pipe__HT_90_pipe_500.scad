$fn = 128;

// Parameters
nominal_size = 90; //[50:180:1]
length_mm = 500; //[250:1000:1]
include_end_fitting = 1; //[0:1:1]
center = 0; //[0:1:1]

pipe_od = 90; //[45:180:1]
wall_thickness = 3.2; //[1.6:6.4:0.1]

socket_od = 98; //[80:140:0.5]
socket_length = 60; //[30:120:1]
socket_wall_extra = 1.8; //[0.8:4:0.1]
socket_bore_clearance = 0.6; //[0.2:1.5:0.1]

overlap = 1; //[0.5:2:0.1]

// Derived
pipe_r = pipe_od/2;
pipe_ir = pipe_r - wall_thickness;

socket_r = socket_od/2;
socket_ir = pipe_r + socket_bore_clearance;

// Safety clamps
pipe_ir_safe   = max(0.01, pipe_ir);
socket_ir_safe = max(0.01, socket_ir);
socket_r_safe  = max(socket_ir_safe + 0.01, socket_r);

// Ensure socket doesn't exceed pipe length
socket_len_safe = min(socket_length, length_mm);

// Place socket at the "top" end (z = length_mm - socket_len_safe ... length_mm)
socket_z0 = length_mm - socket_len_safe;

module ht90_pipe_500() {
    color([0.85, 0.85, 0.8])
    difference() {
        union() {
            // Main outer pipe
            cylinder(h=length_mm, r=pipe_r, center=false);

            // Socket outer (connected by construction)
            if (include_end_fitting && socket_len_safe > 0)
                translate([0, 0, socket_z0])
                    cylinder(h=socket_len_safe, r=socket_r_safe, center=false);
        }

        // Main bore (hollow) - slightly extended for robust boolean
        translate([0, 0, -overlap])
            cylinder(h=length_mm + 2*overlap, r=pipe_ir_safe, center=false);

        // Socket bore (slightly larger ID inside socket region) - extended for robust boolean
        if (include_end_fitting && socket_len_safe > 0)
            translate([0, 0, socket_z0 - overlap])
                cylinder(h=socket_len_safe + 2*overlap, r=socket_ir_safe, center=false);
    }
}

// Centering option
translate([0, 0, -center*(length_mm/2)]) ht90_pipe_500();