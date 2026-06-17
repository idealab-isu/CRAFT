$fn = 128;

// Socket Head Cap Screw
// Shank diameter: 3.0 mm
// Head diameter: 6.0 mm
// Overall length (under head): 10.0 mm

d_shank = 3.0;
d_head  = 6.0;
L_total = 10.0;

// Head + socket proportions (M3-like)
k_head  = 3.0;     // head height
s_hex   = 2.5;     // socket across flats
t_hex   = 1.6;     // socket depth
chamfer = 0.35;    // head edge chamfer

// Thread (simple helical ridge approximation)
pitch        = 0.5;   // coarse M3 pitch
thread_h     = 0.18;  // radial height of thread ridge
thread_w     = 0.28;  // tangential width of ridge
thread_start = 0.6;   // unthreaded length under head
tip_chamfer  = 0.35;  // tip chamfer

module hex_prism_af(af, h){
    // Regular hex with given across-flats (af)
    // For a regular hex, circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

module chamfered_cylinder(d, h, c){
    c2 = min(c, h/2);
    union(){
        translate([0,0,c2]) cylinder(h=max(0, h-2*c2), d=d);
        cylinder(h=c2, d1=max(0.01, d-2*c2), d2=d);
        translate([0,0,h-c2]) cylinder(h=c2, d1=d, d2=max(0.01, d-2*c2));
    }
}

module threaded_shank(d_core, L, pitch, ridge_h, ridge_w, start_unthread, tip_chamfer){
    // Core cylinder with a simple helical ridge to suggest threads.
    // Keeps one connected solid (ridge is unioned to core).
    core_r = d_core/2;
    turns = max(0, (L - start_unthread) / pitch);

    union(){
        // Core
        cylinder(h=L, r=core_r);

        // Tip chamfer (subtract later in main difference for clean end)
        // (kept as core here; chamfer is applied in main difference)

        // Helical ridge (approx thread)
        if (turns > 0)
            translate([0,0,start_unthread])
                linear_extrude(height=L-start_unthread, twist=-360*turns, slices=max(24, ceil(turns*48)))
                    translate([core_r + ridge_h/2, 0, 0])
                        square([ridge_h, ridge_w], center=true);
    }
}

module socket_head_cap_screw(d_shank, d_head, L_total, k_head, s_hex, t_hex, chamfer){
    eps = 0.02;

    difference(){
        union(){
            // Shank (under head): from z=-L_total to z=0
            translate([0,0,-L_total])
                threaded_shank(
                    d_core=d_shank,
                    L=L_total,
                    pitch=pitch,
                    ridge_h=thread_h,
                    ridge_w=thread_w,
                    start_unthread=thread_start,
                    tip_chamfer=tip_chamfer
                );

            // Head: from z=0 to z=k_head
            chamfered_cylinder(d=d_head, h=k_head, c=chamfer);
        }

        // Internal hex socket recess (cut into head from top)
        translate([0,0,k_head - t_hex])
            hex_prism_af(af=s_hex, h=t_hex + 0.3);

        // Lead-in at socket opening (slight countersink)
        lead_h = min(0.7, t_hex);
        translate([0,0,k_head - lead_h])
            cylinder(h=lead_h + 0.01, d1=s_hex*1.18, d2=s_hex*0.98, $fn=64);

        // Tip chamfer at end of shank (cut)
        translate([0,0,-L_total - eps])
            cylinder(h=tip_chamfer + 2*eps, d1=d_shank + 2*thread_h, d2=max(0.01, d_shank - 2*tip_chamfer), $fn=96);
    }
}

socket_head_cap_screw(d_shank, d_head, L_total, k_head, s_hex, t_hex, chamfer);