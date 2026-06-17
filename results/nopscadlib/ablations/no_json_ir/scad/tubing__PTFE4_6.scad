// PTFE tubing (hollow) — ensure visible geometry in all views by orienting along X
// and using robust boolean with slight overlap.

outer_diameter = 10;   // mm
inner_diameter = 8;    // mm
length = 100;          // mm

$fn = 128;
eps = 0.05; // overlap to avoid coplanar/blank boolean artifacts

module tubing(od=outer_diameter, id=inner_diameter, h=length) {
    id2 = min(id, od - 2*eps); // keep a valid wall

    // Build along Z, then rotate so the tube runs along X (front/back/left/right show the bore)
    rotate([0, 90, 0])
    difference() {
        cylinder(d=od, h=h, center=true);
        cylinder(d=id2, h=h + 2*eps, center=true);
    }
}

tubing();