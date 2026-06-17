$fn = 64;

// Overall bounding size must match: [26, 25, 4.7]
size = [26, 25, 4.7];
W = size[0];
H = size[1];
T = size[2];

// Bracket geometry (kept within the bounding box)
leg = 8;                 // width of each leg of the L
corner_r = 2;            // inner corner relief radius
hole_d = 5.2;            // clearance hole
hole_edge = 6.5;         // hole center distance from each outer edge

module l_bracket_2d() {
    difference() {
        union() {
            square([W, leg], center=false);   // bottom leg
            square([leg, H], center=false);   // left leg
        }
        // inner corner relief to emphasize bracket shape
        translate([leg, leg])
            circle(r=corner_r);
    }
}

difference() {
    // L-shaped extrusion bracket plate, extruded to thickness T
    linear_extrude(height=T, center=false)
        l_bracket_2d();

    // Two mounting holes (one per leg), fully through
    for (p = [
        [hole_edge, hole_edge],                 // near corner on bottom leg
        [W - hole_edge, hole_edge]              // along bottom leg toward right
    ]) {
        translate([p[0], p[1], -0.1])
            cylinder(h=T + 0.2, d=hole_d, center=false);
    }

    for (p = [
        [hole_edge, H - hole_edge],             // along left leg toward top
        [hole_edge, hole_edge]                  // shared corner hole (overlaps; subtracting twice is fine)
    ]) {
        translate([p[0], p[1], -0.1])
            cylinder(h=T + 0.2, d=hole_d, center=false);
    }
}