// Dimension-calibrated (target: 0.08 x 0.09 x 0.09 mm)
scale([0.822442, 0.803750, 0.757021])
{
// Textured/studded micro-cube (0.1 x 0.1 x 0.1 mm bounding box)
// One connected solid; all protrusions overlap into the base slightly.

// ---------- Global quality ----------
$fn = 24;

// ---------- Target bounding box ----------
bbox = 0.1;                 // mm (X=Y=Z)
block = bbox;               // base cube size

// ---------- Boss geometry (faceted "diamond" bosses) ----------
boss_corner_d = 0.018;      // across flats (approx) of corner bosses
boss_corner_h = 0.010;

boss_center_d = 0.012;
boss_center_h = 0.007;

extra_d = 0.010;
extra_h = 0.006;

// Placement (corner-adjacent)
corner_off = 0.032;         // distance from center along face axes

// Small overlap to guarantee connectivity
overlap = 0.0015;

// Slight per-face variation (kept deterministic)
j = 0.0015;

// ---------- Helpers ----------
module octa_boss(d, h) {
    // Faceted diamond-like boss: octahedron scaled to height h and width d
    // Octahedron points at +/-Z and +/-X +/-Y (8 faces).
    scale([d/2, d/2, h/2])
        polyhedron(
            points=[
                [ 1, 0, 0], [-1, 0, 0],
                [ 0, 1, 0], [ 0,-1, 0],
                [ 0, 0, 1], [ 0, 0,-1]
            ],
            faces=[
                [4,0,2],[4,2,1],[4,1,3],[4,3,0],
                [5,2,0],[5,1,2],[5,3,1],[5,0,3]
            ]
        );
}

module face_pattern() {
    // 4 corner-adjacent + 1 center
    union() {
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*corner_off, sy*corner_off, 0])
                octa_boss(boss_corner_d, boss_corner_h);
        translate([0,0,0]) octa_boss(boss_center_d, boss_center_h);
    }
}

module face_pattern_with_extras() {
    // Adds a few edge-near extras (still connected via overlap)
    union() {
        face_pattern();
        translate([ 0.0,  0.040, 0]) octa_boss(extra_d, extra_h);
        translate([ 0.0, -0.040, 0]) octa_boss(extra_d, extra_h);
        translate([ 0.040, 0.0, 0]) octa_boss(extra_d, extra_h);
        translate([-0.040, 0.0, 0]) octa_boss(extra_d, extra_h);
    }
}

// Place a pattern onto a given face with correct outward direction.
// We place bosses so their center is slightly inside the cube (overlap),
// ensuring a single connected solid.
module on_face_zp(var=0) {
    translate([var, -var, block/2 - overlap]) face_pattern_with_extras();
}
module on_face_zn(var=0) {
    mirror([0,0,1]) translate([var, var, block/2 - overlap]) face_pattern_with_extras();
}
module on_face_xp(var=0) {
    rotate([0,90,0]) translate([var, -var, block/2 - overlap]) face_pattern_with_extras();
}
module on_face_xn(var=0) {
    rotate([0,-90,0]) translate([var, var, block/2 - overlap]) face_pattern_with_extras();
}
module on_face_yp(var=0) {
    rotate([-90,0,0]) translate([var, -var, block/2 - overlap]) face_pattern_with_extras();
}
module on_face_yn(var=0) {
    rotate([90,0,0]) translate([var, var, block/2 - overlap]) face_pattern_with_extras();
}

// ---------- Model ----------
union() {
    // Base cube
    cube([block, block, block], center=true);

    // Six faces (slight deterministic variation per face)
    on_face_zp( 0.0);
    on_face_zn( j);
    on_face_xp(-j);
    on_face_xn( 0.5*j);
    on_face_yp(-0.5*j);
    on_face_yn( 0.25*j);
}
}
