// Dimension-calibrated (target: 10.00 x 18.00 x 6.35 mm)
scale([0.800000, 1.000000, 0.599057])
{
// Push-in clip / split-prong rivet (flange + straight shank + split tapered prongs)
// Target bounding box: ~10.0 x 18.0 x 6.3 mm (W x L x H), elongated along X

$fn = 96;

// Bounding box targets
bbox_L = 18.0;   // overall length along X
bbox_W = 10.0;   // overall width along Y (set by head_d)
bbox_H = 6.35;   // overall height along Z (set by shank_d / prong_thk)

// Head (flange)
head_d = 10.0;   // sets bbox_W
head_t = 2.2;

// Shank (straight cylinder)
shank_d = 6.0;   // sets bbox_H (<= 6.35)
shank_L_to_split = 10.0;

// Prongs (fork)
prong_L = 5.8;           // nominal, clamped by bbox_L
prong_thk = 2.6;         // thickness in Z of prongs
v_gap_w = 1.2;           // gap between prongs in Y
prong_base_w_each = 2.8; // each prong width in Y at base
prong_tip_w_each  = 1.6; // each prong width in Y at tip

// Tip shaping
tip_chamfer_L = 1.2;     // length of tip wedge cut
tip_chamfer_ang = 25;    // degrees

// Small overlaps to guarantee one connected solid
overlap = 0.6;

// Derived / enforced lengths (no arbitrary translates)
shank_L_total = bbox_L - head_t;                 // from head underside to free end
split_start_x = head_t + shank_L_to_split;       // where fork begins (from X=0 head front)
prong_start_x = split_start_x;
prong_end_x   = head_t + shank_L_total;          // must end at bbox_L
prong_L_eff   = max(prong_end_x - prong_start_x, 0.01);

// Clamp user prong_L if it would exceed bbox
// (keeps split start fixed, end fixed at bbox_L)
prong_L_eff2 = prong_L_eff;

// Coordinate system: X length axis, head spans X=[0..head_t], tip at X=bbox_L

module head_flange() {
    translate([head_t/2, 0, 0])
        cylinder(h=head_t, r=head_d/2, center=true);
}

module shank_cyl() {
    // Straight cylinder from head underside (x=head_t) to split start (x=split_start_x)
    shank_len = shank_L_to_split;
    translate([head_t + shank_len/2 - overlap/2, 0, 0])
        cylinder(h=shank_len + overlap, r=shank_d/2, center=true);
}

module fork_prongs() {
    // Build two separate tapered prongs and union them, then chamfer the tips.
    // Each prong is a hull between a base and tip rectangle (extruded along X).
    base_x = prong_start_x - overlap/2;
    tip_x  = prong_end_x   + overlap/2;

    // Place prongs symmetrically about Y=0, leaving a V-gap (actually a straight slot gap)
    y_off_base = v_gap_w/2 + prong_base_w_each/2;
    y_off_tip  = v_gap_w/2 + prong_tip_w_each/2;

    module one_prong(sign=1) {
        hull() {
            translate([base_x, sign*y_off_base, 0])
                cube([overlap, prong_base_w_each, prong_thk], center=true);
            translate([tip_x, sign*y_off_tip, 0])
                cube([overlap, prong_tip_w_each, prong_thk], center=true);
        }
    }

    module tip_chamfer_cut() {
        // Subtract a wedge near the tip to create a push-in lead and make prongs read as tapered.
        // Cut spans full Y/Z so both prongs are chamfered consistently.
        cut_x = prong_end_x - tip_chamfer_L/2;
        translate([cut_x, 0, 0])
            rotate([0, tip_chamfer_ang, 0])
                cube([tip_chamfer_L*2, bbox_W*2, bbox_H*2], center=true);
    }

    difference() {
        union() {
            // Small cylindrical neck to ensure robust connection at split start
            translate([prong_start_x - overlap/2, 0, 0])
                cylinder(h=overlap*2, r=shank_d/2, center=true);

            one_prong(+1);
            one_prong(-1);
        }
        tip_chamfer_cut();
    }
}

union() {
    head_flange();
    shank_cyl();
    fork_prongs();
}
}
