// Parameters
pipe_standard = 0; //[0:0:1]
nominal_diameter_mm = 90; //[45:180:1]
length_mm = 250; //[125:500:1]
orientation = 0; //[0:0:1]
center = 0; //[0:0:1]
pipe_od = 90; //[45:180:1]
pipe_wall = 3.2; //[1.6:6.4:0.1]
socket_length = 45; //[22.5:90:1]
socket_wall_extra = 2.0; //[1.0:4.0:0.1]
socket_clearance = 0.6; //[0.2:1.2:0.1]
connect_overlap = 1.0; //[0.5:2.0:0.1]

$fn = 128;

// HT Pipe - complete geometry (ONE connected solid)
module ht_pipe() {
    // Derived radii
    outer_r = pipe_od/2;
    inner_r = max(0.01, outer_r - pipe_wall);

    socket_outer_r = outer_r + socket_wall_extra;
    socket_inner_r = outer_r + socket_clearance;

    // Ensure socket inner radius is smaller than socket outer radius
    socket_inner_r = min(socket_inner_r, socket_outer_r - 0.2);

    // Z placement (computed, not arbitrary)
    body_z0 = 0;
    body_z1 = length_mm;

    socket_z0 = body_z1 - connect_overlap;
    socket_z1 = socket_z0 + socket_length;

    // Small epsilon to avoid coplanar faces in differences
    eps = 0.02;

    color([0.85, 0.85, 0.8]) {
        difference() {
            // OUTER solid: pipe body + socket sleeve (overlapped so it's connected)
            union() {
                translate([0, 0, body_z0])
                    cylinder(h=length_mm, r=outer_r, center=false);

                translate([0, 0, socket_z0])
                    cylinder(h=socket_length, r=socket_outer_r, center=false);
            }

            // INNER void: pipe bore + socket bore (slightly extended to guarantee clean subtraction)
            union() {
                translate([0, 0, body_z0 - eps])
                    cylinder(h=length_mm + 2*eps, r=inner_r, center=false);

                translate([0, 0, socket_z0 - eps])
                    cylinder(h=socket_length + 2*eps, r=socket_inner_r, center=false);
            }
        }
    }
}

// Assembly
module assembly() {
    ht_pipe();
}

assembly();