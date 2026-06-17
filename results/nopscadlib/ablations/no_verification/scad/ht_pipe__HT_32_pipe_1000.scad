// HT 32 pipe 1000 mm (simple parametric model)
// One connected solid, centered for reliable orthographic views.

$fn = 128;

// Parameters
nominal_size = 32;          // informational
length_mm = 1000;           // pipe length
pipe_od = 32;               // outer diameter
pipe_wall = 1.8;            // wall thickness

socket_len = 25;            // socket (muff) length
socket_od_scale = 1.15;     // socket OD relative to pipe OD
socket_wall_scale = 1.2;    // socket wall relative to pipe wall

overlap = 1;                // overlap to guarantee connectivity
eps = 0.02;                 // small epsilon for robust booleans

module ht_pipe_32_1000() {
    pipe_r = pipe_od/2;
    pipe_ir = max(0.1, pipe_r - pipe_wall);

    socket_od = pipe_od * socket_od_scale;
    socket_r  = socket_od/2;
    socket_wall = pipe_wall * socket_wall_scale;
    socket_ir = max(0.1, socket_r - socket_wall);

    // Center the whole part on Z for better visibility in all ortho views
    translate([0, 0, -length_mm/2])
    color([0.85, 0.85, 0.80])
    difference() {
        // OUTER: pipe + socket (unioned and overlapped)
        union() {
            // Main pipe outer
            cylinder(h=length_mm, r=pipe_r, center=false);

            // Socket outer at one end, overlapped into pipe by 'overlap'
            translate([0, 0, length_mm - socket_len - overlap])
                cylinder(h=socket_len + overlap, r=socket_r, center=false);
        }

        // INNER VOID: through-bore + socket inner (unioned)
        union() {
            // Through-bore (slightly extended to avoid coplanar faces)
            translate([0, 0, -eps])
                cylinder(h=length_mm + 2*eps, r=pipe_ir, center=false);

            // Socket inner cavity (larger ID than pipe ID), slightly extended
            translate([0, 0, length_mm - socket_len - overlap - eps])
                cylinder(h=socket_len + overlap + 2*eps, r=socket_ir, center=false);
        }
    }
}

ht_pipe_32_1000();