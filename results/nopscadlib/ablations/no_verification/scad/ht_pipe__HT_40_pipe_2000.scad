// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 40; //[20:80:1]
length_mm = 2000; //[1000:4000:10]
ht40_outer_diameter = 40; //[30:60:0.5]
ht40_wall_thickness = 1.8; //[1:4:0.1]
end_interface_length = 25; //[10:60:1]
end_interface_radial_add = 2; //[0.5:6:0.5]
connect_overlap = 1; //[0.5:2:0.1]

$fn = 128;

// HT Pipe - one connected solid, centered for reliable orthographic views
module ht_pipe() {
    od      = ht40_outer_diameter;
    wt      = ht40_wall_thickness;
    L       = length_mm;
    sockL   = end_interface_length;
    sockAdd = end_interface_radial_add;
    ov      = connect_overlap;

    // Safety clamps
    wt_eff = min(wt, od/2 - 0.2);
    id     = od - 2*wt_eff;
    ir     = id/2;

    // Center the whole part on Z so front/back/left/right views show geometry
    translate([0, 0, -L/2])
    color([0.85, 0.85, 0.8])
    difference() {
        // OUTER: main pipe + socket (single connected solid)
        union() {
            // Main outer cylinder
            cylinder(h=L, r=od/2, center=false);

            // Socket outer cylinder at the +Z end, connected by construction
            translate([0, 0, L - sockL])
                cylinder(h=sockL, r=od/2 + sockAdd, center=false);
        }

        // INNER VOID: continuous bore through entire length (including socket)
        translate([0, 0, -ov])
            cylinder(h=L + 2*ov, r=ir, center=false);
    }
}

ht_pipe();