// Flat washer: 5.0mm ID, 10.0mm OD, 1.0mm thickness (single connected solid)

// Dimensions (mm)
id  = 5.0;
od  = 10.0;
thk = 1.0;

// Make circles truly round in renders
$fa = 2;      // max angle per fragment (deg)
$fs = 0.2;    // max size per fragment (mm)
$fn = 0;      // let $fa/$fs control resolution

module washer(id, od, thk) {
    difference() {
        cylinder(h = thk, r = od/2, center = true);
        cylinder(h = thk + 0.2, r = id/2, center = true); // slight extra height ensures clean through-hole
    }
}

washer(id, od, thk);