// Dimension-calibrated (target: 0.03 x 0.03 x 0.02 mm)
scale([0.001000, 0.000962, 0.001111])
{
// Flanged bushing/spacer: cylindrical sleeve + hex flange (no hole)
// Fixes:
// - Remove bbox intersection cube that made the body look prismatic
// - Ensure cylinder + hex flange are connected with computed placement + slight overlap
// - Use consistent dimensions (bbox_* not used as geometry limits)

$fn = 96;

// Parameters (mm)
body_d    = 20;
body_h    = 14;

flange_af = 30;   // hex across flats
flange_h  = 6;

overlap   = 0.2;  // small overlap to guarantee one connected solid

// Helpers
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for regular hex given across-flats

module hex_prism(af, h) {
    // Regular hex with flats horizontal (as in provided views)
    linear_extrude(height=h, center=true)
        polygon(points=[
            [ af/2, 0],
            [ af/4,  af*sqrt(3)/4],
            [-af/4,  af*sqrt(3)/4],
            [-af/2, 0],
            [-af/4, -af*sqrt(3)/4],
            [ af/4, -af*sqrt(3)/4]
        ]);
}

module model() {
    union() {
        // Main cylindrical body: bottom at z=0, top at z=body_h
        translate([0, 0, body_h/2])
            cylinder(h=body_h, r=body_d/2, center=true);

        // Hex flange on top end: bottom slightly overlaps body top
        translate([0, 0, body_h + flange_h/2 - overlap])
            hex_prism(flange_af, flange_h);
    }
}

color("Silver") model();
}
