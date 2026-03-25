// Dimension-calibrated (target: 0.36 x 0.03 x 0.54 mm)
scale([1.080000, 0.900000, 0.789490])
{
// Thin rectangular plate with a centered rectangular boss (raised pad)
// Units: mm

// Target bounding box (approx): 0.4 x 0.0 x 0.5 mm (elongated along one axis)
L = 0.50;   // length (elongated axis)
W = 0.40;   // width
T = 0.03;   // plate thickness

// Boss (centered pad) size
boss_L = 0.20;
boss_W = 0.14;
boss_H = 0.01;

// Small overlap to guarantee a single manifold solid
overlap = 0.002;

union() {
    // Base plate centered at origin
    cube([L, W, T], center=true);

    // Boss protruding from the +Z face, centered in plan view
    translate([0, 0, (T/2) + (boss_H/2) - overlap])
        cube([boss_L, boss_W, boss_H], center=true);
}
}
