$fn = 64;

sheet_len = 200;
sheet_wid = 120;
sheet_thk = 2.0;

edge_round = 0.6;          // small edge radius
weave_pitch = 6.0;         // mm between weave cells
weave_depth = 0.08;        // emboss depth (subtle)
weave_margin = 1.2;        // keep weave away from edges

module rounded_plate(l, w, t, r){
    r2 = min(r, min(l, w)/2);
    linear_extrude(height=t)
        offset(r=r2)
            square([l-2*r2, w-2*r2], center=true);
}

module carbon_weave_top(l, w, t, pitch, depth, margin){
    // Embossed weave pattern on top surface only
    // Uses two diagonal stripe sets intersected with the sheet footprint.
    stripe_w = pitch * 0.55;
    big = max(l, w) * 3;

    translate([0,0,t - depth])
    intersection(){
        // footprint (slightly inset)
        linear_extrude(height=depth)
            offset(delta=-margin)
                square([l, w], center=true);

        union(){
            // +45° stripes
            rotate([0,0,45])
            for (x = [-big : pitch : big])
                translate([x,0,0])
                    cube([stripe_w, big*2, depth], center=true);

            // -45° stripes
            rotate([0,0,-45])
            for (x = [-big : pitch : big])
                translate([x,0,0])
                    cube([stripe_w, big*2, depth], center=true);
        }
    }
}

union(){
    // Base sheet
    color([0.06, 0.06, 0.07])
        rounded_plate(sheet_len, sheet_wid, sheet_thk, edge_round);

    // Subtle weave emboss
    color([0.10, 0.10, 0.11])
        carbon_weave_top(sheet_len, sheet_wid, sheet_thk, weave_pitch, weave_depth, weave_margin);
}