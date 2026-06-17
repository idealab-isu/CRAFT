// Socket head cap screw (M4 x 10) - connected solid with visible hex socket

$fn = 120;

// Dimensions (mm)
shank_d = 4.0;
shank_L = 10.0;          // under-head length
head_d  = 7.0;
head_H  = 4.0;

// Hex socket (across flats) and depth
socket_af    = 3.0;
socket_depth = 2.5;

// Small edge details
tip_chamfer       = 0.3;
head_top_chamfer  = 0.3;

// Boolean robustness overlap
overlap = 0.2;

// Derived
total_L = shank_L + head_H;

// Helpers
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for regular hex given across-flats

module hex_prism(af, h, center=false) {
    R = hex_R_from_AF(af);
    linear_extrude(height=h, center=center, convexity=10)
        polygon(points=[ for (i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

module screw() {
    difference() {
        union() {
            // Shank: from z=0 (under head) down to z=-shank_L
            translate([0,0,-shank_L/2])
                cylinder(h=shank_L, r=shank_d/2, center=true);

            // Tip chamfer at bottom end (kept within shank length)
            translate([0,0,-shank_L + tip_chamfer/2])
                cylinder(h=tip_chamfer, r1=shank_d/2, r2=max(0.01, shank_d/2 - tip_chamfer), center=true);

            // Head: from z=0 up to z=head_H
            translate([0,0, head_H/2])
                cylinder(h=head_H, r=head_d/2, center=true);

            // Top chamfer on head (kept within head height)
            translate([0,0, head_H - head_top_chamfer/2])
                cylinder(h=head_top_chamfer,
                         r1=head_d/2,
                         r2=max(0.01, head_d/2 - head_top_chamfer),
                         center=true);
        }

        // Hex socket recess from top face downward
        translate([0,0, head_H - socket_depth/2 + overlap/2])
            hex_prism(socket_af, socket_depth + overlap, center=true);
    }
}

screw();