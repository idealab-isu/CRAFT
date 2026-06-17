// Socket Head Cap Screw (M6x10) simplified but proportion-correct
// Request: shank Ø6.0, head Ø10.0, head height 6.0, length 10mm (measured under head)

$fn = 128;

// --- Primary dimensions (mm) ---
d_shank   = 6.0;     // shank major diameter
L_under   = 10.0;    // length under head (standard SHCS length callout)

d_head = 10.0;
h_head = 6.0;

// Socket (typical for M6 SHCS is 5mm AF)
socket_af    = 5.0;
socket_depth = 4.0;

// Thread (approx ISO M6 coarse)
pitch = 1.0;

// Overlaps for robust unions / cutters
overlap = 1.0;       // 1–2mm requested
top_chamfer_h = 0.6;
tip_chamfer_h = 0.6;

// Derived
L_overall = L_under + h_head;   // total length including head
thread_len = L_under;           // fully threaded under head (simplified)

// --- Helpers ---
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for hex with across-flats = af

module hex_prism(af, h, center=false) {
    rotate([0,0,30])
        cylinder(h=h, r=hex_R_from_AF(af), $fn=6, center=center);
}

// Simple external thread approximation using a helical triangular ridge.
// Keeps one connected solid and gives a threaded silhouette.
module external_thread(d_major, pitch, len, depth=0.45, crest_flat=0.18) {
    r_major = d_major/2;
    r_root  = r_major - depth;

    union() {
        // Root/core cylinder
        cylinder(h=len, r=r_root, center=false);

        // Helical ridge
        linear_extrude(height=len, twist=360*len/pitch, slices=max(ceil(len*24), 80), convexity=10)
            translate([r_root, 0, 0])
                polygon(points=[
                    [0, -pitch*(0.25 - crest_flat/2)],
                    [depth, 0],
                    [0,  pitch*(0.25 - crest_flat/2)]
                ]);
    }
}

module socket_head_cap_screw() {
    difference() {
        union() {
            // Threaded shank: z = 0 .. L_under
            external_thread(d_major=d_shank, pitch=pitch, len=thread_len, depth=0.45, crest_flat=0.18);

            // Under-head blend (conical) to connect shank to head with overlap
            blend_h = min(1.2, h_head*0.35);
            translate([0,0,L_under - blend_h])
                cylinder(h=blend_h + overlap, r1=d_shank/2, r2=d_head/2, center=false);

            // Head: z = L_under .. L_under + h_head
            translate([0,0,L_under])
                cylinder(h=h_head, r=d_head/2, center=false);
        }

        // Top chamfer cutter (slight bevel on head top edge)
        translate([0,0,L_overall - top_chamfer_h])
            cylinder(h=top_chamfer_h + overlap, r1=d_head/2, r2=max(d_head/2 - top_chamfer_h, 0.01), center=false);

        // Tip chamfer cutter (slight bevel on shank end)
        translate([0,0,-overlap])
            cylinder(h=tip_chamfer_h + overlap, r1=max(d_shank/2 - tip_chamfer_h, 0.01), r2=d_shank/2, center=false);

        // Hex socket recess: cut from top down
        translate([0,0,L_overall - socket_depth])
            hex_prism(socket_af, socket_depth + overlap, center=false);
    }
}

socket_head_cap_screw();