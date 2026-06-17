// Dimension-calibrated (target: 0.22 x 0.08 x 0.01 mm)
scale([0.796429, 0.962500, 1.500000])
{
$fn = 96;

// Parameters (mm)
L = 0.22;          // overall length target (approx)
W = 0.10;          // overall width target (approx)
T = 0.01;          // plate thickness

shank_L = 0.14;
shank_W = 0.03;

bow_OD = 0.08;
bow_ID = 0.04;

bit_L = 0.06;
bit_W = 0.04;

step1_L = 0.02;
step1_depth = 0.01;

step2_L = 0.015;
step2_depth = 0.015;

tooth_L = 0.015;
tooth_H = 0.02;

eps = 0.001;

// Derived placement (all formulas, no arbitrary offsets)
bow_cx = bow_OD/2;                 // put bow at left so total length is controlled by bit end
bow_cy = W/2;

shank_x0 = bow_cx + bow_OD/2;      // shank starts at bow outer right edge
shank_x1 = shank_x0 + shank_L;     // shank ends at bit start

bit_x0 = shank_x1;                 // bit starts at shank end
bit_x1 = bit_x0 + bit_L;           // bit ends at far right

// 2D profile of the key (flat plate), then extruded once
module key_2d() {
    difference() {
        union() {
            // Bow (outer disk)
            translate([bow_cx, bow_cy]) circle(r=bow_OD/2);

            // Shank (rectangle) - connected to bow by overlap at x = shank_x0
            translate([shank_x0 - eps, bow_cy - shank_W/2])
                square([shank_L + eps, shank_W]);

            // Bit base (rectangle) - connected to shank
            translate([bit_x0 - eps, bow_cy - bit_W/2])
                square([bit_L + eps, bit_W]);

            // Triangular tooth on upper edge near bit tip
            // Base sits on top edge of bit, protrudes upward
            polygon(points=[
                [bit_x1 - tooth_L, bow_cy + bit_W/2],
                [bit_x1,          bow_cy + bit_W/2],
                [bit_x1 - tooth_L, bow_cy + bit_W/2 + tooth_H]
            ]);
        }

        // Concentric circular through-hole in bow
        translate([bow_cx, bow_cy]) circle(r=bow_ID/2);

        // Stepped rectangular notches cut from lower edge of bit
        // Step 1 (shallower)
        translate([bit_x0, bow_cy - bit_W/2])
            square([step1_L, step1_depth]);

        // Step 2 (deeper), immediately after step 1
        translate([bit_x0 + step1_L, bow_cy - bit_W/2])
            square([step2_L, step2_depth]);
    }
}

// Final solid: single connected plate-like key
linear_extrude(height=T, center=true, convexity=10)
    key_2d();
}
