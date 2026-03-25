// Dimension-calibrated (target: 0.30 x 0.32 x 0.01 mm)
scale([0.990625, 0.953125, 1.300218])
{
// Thin keyed plate with centered edge tabs (single connected solid)

// Overall target bounding box ~0.3 x 0.3 x ~0.01 mm
plate_X = 0.30;   // width (left-right)
plate_Y = 0.30;   // length (front-back)
plate_Z = 0.01;   // thickness

// Tab geometry (protrude outward from edges)
tab_out = 0.01;   // protrusion distance outward from the plate edge
tab_len = 0.08;   // length along the edge (centered)
tab_Z   = plate_Z;

// Small overlap to guarantee manifold union
eps = 0.002;

// Base plate
module base_plate() {
    cube([plate_X, plate_Y, plate_Z], center=true);
}

// Centered tab on +Y edge
module tab_posY() {
    translate([0, plate_Y/2 + tab_out/2 - eps, 0])
        cube([tab_len, tab_out + 2*eps, tab_Z], center=true);
}

// Centered tab on -Y edge
module tab_negY() {
    translate([0, -(plate_Y/2 + tab_out/2 - eps), 0])
        cube([tab_len, tab_out + 2*eps, tab_Z], center=true);
}

// Centered tab on -X edge
module tab_negX() {
    translate([-(plate_X/2 + tab_out/2 - eps), 0, 0])
        cube([tab_out + 2*eps, tab_len, tab_Z], center=true);
}

// Centered tab on +X edge
module tab_posX() {
    translate([plate_X/2 + tab_out/2 - eps, 0, 0])
        cube([tab_out + 2*eps, tab_len, tab_Z], center=true);
}

// Build: include all tabs so silhouette matches; front/back "difference" is view-dependent.
union() {
    base_plate();
    tab_posY();
    tab_negY();
    tab_negX();
    tab_posX();
}
}
