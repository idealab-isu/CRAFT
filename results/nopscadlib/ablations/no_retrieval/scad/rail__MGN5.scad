// Miniature linear guide rail (single connected solid)
// Target overall size: 100.0mm (L) x 5.0mm (W) x 3.6mm (H)

$fn = 64;

// Parameters
rail_L = 100.0; //[50.0:200.0:1]
rail_W = 5.0;   //[2.5:10.0:0.1]
rail_H = 3.6;   //[1.8:7.2:0.1]

// Mounting holes
hole_d = 2.0;                 //[1.0:4.0:0.1]
hole_pitch = 20.0;            //[10.0:40.0:1]
hole_edge_offset = 10.0;      //[5.0:20.0:1]
hole_count = 5;               //[2:9:1]
hole_clearance_factor = 1.05; //[1.0:1.2:0.01]

// Profile details (subtractive)
race_r = 0.85;        //[0.4:1.2:0.05]  // side raceway radius
race_depth = 0.55;    //[0.2:1.0:0.05]  // how far into the side
race_z = 0.55;        //[0.2:1.2:0.05]  // vertical offset from top/bottom edges

// End chamfers (subtractive)
end_chamfer_L = 1.0;  //[0.3:2.0:0.1]

// Small top relief groove (subtractive)
top_groove_W = 0.7;   //[0.2:1.5:0.05]
top_groove_D = 0.25;  //[0.05:0.6:0.05]
top_groove_L = 70.0;  //[20.0:120.0:1]

// Robust boolean overlap
overlap = 0.8; //[0.5:2.0:0.1]

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Ensure grooves don't exceed rail bounds
race_r_eff     = clamp(race_r, 0.05, rail_H/2 - 0.05);
race_depth_eff = clamp(race_depth, 0.05, rail_W/2 - 0.05);
race_z_eff     = clamp(race_z, 0.05, rail_H/2 - race_r_eff - 0.05);

top_groove_W_eff = clamp(top_groove_W, 0.05, rail_W - 0.2);
top_groove_D_eff = clamp(top_groove_D, 0.01, rail_H/2 - 0.05);
top_groove_L_eff = clamp(top_groove_L, 1, rail_L - 2*end_chamfer_L - 0.2);

// ---------- Base body ----------
module rail_body() {
    cube([rail_L, rail_W, rail_H], center=true);
}

// Through mounting hole at x
module mounting_hole(x_offset) {
    translate([x_offset, 0, 0])
        cylinder(h=rail_H + 2*overlap,
                 r=(hole_d*hole_clearance_factor)/2,
                 center=true);
}

// End chamfer cut (45° wedge) at +/- end
module end_chamfer(sign=1) {
    // Place a rotated cutting block so it intersects the end
    // sign=+1 for +X end, sign=-1 for -X end
    translate([sign*(rail_L/2 - end_chamfer_L/2), 0, 0])
        rotate([0, sign*45, 0])
            cube([end_chamfer_L + 2*overlap, rail_W + 2*overlap, rail_H + 2*overlap], center=true);
}

// Side raceway cut: cylinder along X, offset to bite into side
module side_raceway(side=1, zpos=1) {
    // side: +1 for +Y side, -1 for -Y side
    // zpos: +1 near top, -1 near bottom
    translate([0,
               side*(rail_W/2 - race_depth_eff),
               zpos*(rail_H/2 - race_z_eff - race_r_eff)])
        rotate([0, 90, 0])
            cylinder(h=rail_L + 2*overlap, r=race_r_eff, center=true);
}

// Top relief groove (shallow rectangular groove)
module top_relief_groove() {
    translate([0, 0, rail_H/2 - top_groove_D_eff/2])
        cube([top_groove_L_eff, top_groove_W_eff, top_groove_D_eff + overlap], center=true);
}

// ---------- Complete model ----------
module complete_model() {
    difference() {
        rail_body();

        // Holes
        for (i = [0:hole_count-1]) {
            mounting_hole(-rail_L/2 + hole_edge_offset + i*hole_pitch);
        }

        // End chamfers
        end_chamfer(+1);
        end_chamfer(-1);

        // Raceway details (4 grooves: two per side, top/bottom)
        side_raceway(+1, +1);
        side_raceway(+1, -1);
        side_raceway(-1, +1);
        side_raceway(-1, -1);

        // Small top groove
        top_relief_groove();
    }
}

complete_model();