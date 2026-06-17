// Dimension-calibrated (target: 0.03 x 0.05 x 0.02 mm)
scale([0.000566, 0.001000, 0.001031])
{
// Spool / standoff-like double-ended bracket
// Units: mm
// One connected solid, obround end flanges, through-holes near outer edges, raised lugs on opposite sides.

$fn = 96;

// -------------------- Parameters --------------------
web_L = 26;
web_W = 12;
web_H = 12;

flange_L = 12;          // length of obround along X
flange_W = 30;          // width of obround along Y
flange_H = 12;

hole_d = 4;
hole_edge_offset = 4;   // from outermost end of flange along X

lug_L = 4;
lug_W = 6;
lug_H = 8;
lug_side_offset = 6;    // Y offset from centerline

overlap = 0.6;          // small overlap to guarantee connectivity
hole_extra_h = 2;       // extra height for clean subtraction

// -------------------- Helpers --------------------
module obround2d(len, wid) {
    // 2D capsule/obround: overall length=len, width=wid
    r = wid/2;
    hull() {
        translate([-(len/2 - r), 0]) circle(r=r);
        translate([ +(len/2 - r), 0]) circle(r=r);
    }
}

module flange_at(xc) {
    translate([xc, 0, 0])
        linear_extrude(height=flange_H, center=true)
            obround2d(flange_L, flange_W);
}

module web() {
    cube([web_L, web_W, web_H], center=true);
}

module lug_at(xc, ysign) {
    // Lug sits on top of flange, offset in Y; overlaps slightly into flange for connectivity
    translate([xc, ysign*lug_side_offset, flange_H/2 + lug_H/2 - overlap])
        cube([lug_L, lug_W, lug_H], center=true);
}

module hole_at(xc, xsign) {
    // Hole near outer edge of flange (toward +/-X)
    // Outer end of flange is at xc + xsign*(flange_L/2)
    x_hole = xc + xsign*(flange_L/2 - hole_edge_offset);
    translate([x_hole, 0, 0])
        cylinder(h=max(web_H, flange_H) + hole_extra_h, r=hole_d/2, center=true);
}

// -------------------- Build --------------------
x_flange = web_L/2 + flange_L/2 - overlap;

module solid_no_holes() {
    union() {
        web();
        flange_at(-x_flange);
        flange_at( x_flange);

        // Opposed lugs for symmetric double-ended mounting geometry
        lug_at(-x_flange, +1);
        lug_at( x_flange, -1);
    }
}

module final_model() {
    difference() {
        solid_no_holes();
        hole_at(-x_flange, -1);
        hole_at( x_flange, +1);
    }
}

// -------------------- Output --------------------
color("Silver") final_model();
}
