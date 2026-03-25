// Dimension-calibrated (target: 0.01 x 0.01 x 0.01 mm)
scale([0.000133, 0.000133, 0.000132])
{
// Simple block with centered cylindrical boss (one connected solid)

// Use sensible, visible millimeter-scale dimensions (avoid near-zero sizes)
block_L = 60;   // length (X)
block_W = 60;   // width  (Y)
block_H = 30;   // height (Z)

boss_r  = 10;   // boss radius
boss_h  = 8;    // boss height
overlap = 0.2;  // small overlap to guarantee manifold union

$fn = 96;

// Base shapes
module block() {
    cube([block_L, block_W, block_H], center=true);
}

module cylindrical_boss() {
    // Centered on the top face of the block
    translate([0, 0, block_H/2 + boss_h/2 - overlap])
        cylinder(h=boss_h, r=boss_r, center=true);
}

// Final model (single connected solid)
union() {
    block();
    cylindrical_boss();
}
}
