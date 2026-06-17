$fn=64;

W = 31.8;
H = 31.8;
T = 15.8;

module boss(cx, cy, sx, sy, sz=T){
    translate([cx, cy, 0]) cube([sx, sy, sz], center=true);
}

module c_bracket(){
    difference(){
        union(){
            // Base plate
            cube([W, H, T], center=true);

            // Outer stepped bosses/pads (reinforcements)
            boss(-W/2 + 4.2,  H/2 - 4.2, 8.4, 8.4);
            boss( W/2 - 4.2,  H/2 - 4.2, 8.4, 8.4);
            boss(-W/2 + 4.2, -H/2 + 4.2, 8.4, 8.4);

            // End pads along right side (clamp-like)
            boss( W/2 - 3.2,  0, 6.4, 12.0);
            boss( W/2 - 3.2,  H/2 - 10.0, 6.4, 8.0);
            boss( W/2 - 3.2, -H/2 + 10.0, 6.4, 8.0);

            // Mid rib on left side
            boss(-W/2 + 3.0, 0, 6.0, 10.0);
        }

        // Main inner rectangular opening
        translate([0, 0, 0]) cube([18.6, 18.6, T+0.4], center=true);

        // Create C-shaped gap opening to the right edge
        translate([W/2 - 4.6, 0, 0]) cube([9.2, 12.8, T+0.6], center=true);

        // Inner step transitions (small notches) to make stepped inner corners
        translate([ 18.6/2 - 1.2,  18.6/2 - 1.2, 0]) cube([2.4, 2.4, T+0.6], center=true);
        translate([ 18.6/2 - 1.2, -18.6/2 + 1.2, 0]) cube([2.4, 2.4, T+0.6], center=true);
        translate([-18.6/2 + 1.2,  18.6/2 - 1.2, 0]) cube([2.4, 2.4, T+0.6], center=true);
        translate([-18.6/2 + 1.2, -18.6/2 + 1.2, 0]) cube([2.4, 2.4, T+0.6], center=true);

        // Additional inner step near the C-gap to suggest clamp throat
        translate([18.6/2 + 1.6, 0, 0]) cube([3.2, 8.0, T+0.6], center=true);
        translate([18.6/2 + 3.6, 0, 0]) cube([2.0, 5.2, T+0.6], center=true);
    }
}

c_bracket();