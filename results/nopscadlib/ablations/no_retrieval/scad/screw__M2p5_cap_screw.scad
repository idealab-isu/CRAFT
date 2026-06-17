// Socket head cap screw (simplified, no threads)
// Dimensions requested:
// shank dia = 2.5mm, head dia = 4.5mm, head height = 2.5mm, overall length = 10mm

$fn = 96;

// --- Parameters (mm) ---
d_shank   = 2.5;
d_head    = 4.5;
h_head    = 2.5;
L_overall = 10;

socket_hex_af = 2.0;   // internal hex across flats (approx for this size)
socket_depth  = 1.6;   // recess depth

// Small edge treatments
top_chamfer = 0.25;    // head top chamfer height
tip_chamfer = 0.35;    // shank tip chamfer height
eps         = 0.02;    // overlap/robustness

// Derived
L_shank = L_overall - h_head;

// --- Helpers ---
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for regular hex given across-flats

module hex_prism(af, h, center=false) {
    R = hex_R_from_AF(af);
    linear_extrude(height=h, center=center)
        polygon([ for (i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

// --- Main model ---
module socket_head_cap_screw() {
    difference() {
        union() {
            // Head: cylinder with slight top chamfer (frustum)
            translate([0,0,L_shank])
            union() {
                // main head body (minus chamfer height)
                cylinder(h=h_head - top_chamfer, r=d_head/2);

                // top chamfer
                translate([0,0,h_head - top_chamfer])
                    cylinder(h=top_chamfer, r1=d_head/2, r2=max(d_head/2 - top_chamfer, 0.01));
            }

            // Shank: cylinder with slight tip chamfer
            union() {
                // main shank
                cylinder(h=max(L_shank - tip_chamfer, 0), r=d_shank/2);

                // tip chamfer (at bottom end)
                if (tip_chamfer > 0)
                    translate([0,0,max(L_shank - tip_chamfer, 0)])
                        cylinder(h=tip_chamfer, r1=d_shank/2, r2=max(d_shank/2 - tip_chamfer, 0.01));
            }
        }

        // Internal hex socket recess (subtracted from head top)
        // Place so its top is flush with head top surface.
        translate([0,0,L_shank + h_head - socket_depth])
            hex_prism(socket_hex_af, socket_depth + eps, center=false);
    }
}

socket_head_cap_screw();