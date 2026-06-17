// Hex nut: 6.0mm through-hole, 11.5mm across flats, 5.0mm thick
$fn = 96;

// Target dimensions
across_flats = 11.5;
thickness    = 5.0;
hole_diameter = 6.0;

// Edge treatment (simple chamfer)
chamfer_height = 0.5;   // along Z
chamfer_inset  = 0.5;   // radial inset at chamfer
eps = 0.02;             // small overlap to avoid coplanar artifacts

// Derived radii
// For a regular hex: across_flats = 2 * apothem, and apothem = R * cos(30)
R_outer = (across_flats/2) / cos(30);                 // circumradius (vertex radius)
R_chamf = max(0, R_outer - chamfer_inset);            // chamfered circumradius

module hex2d(R) {
    polygon(points=[
        [ R, 0],
        [ R*0.5,  R*sqrt(3)/2],
        [-R*0.5,  R*sqrt(3)/2],
        [-R, 0],
        [-R*0.5, -R*sqrt(3)/2],
        [ R*0.5, -R*sqrt(3)/2]
    ]);
}

module nut_solid() {
    difference() {
        // Outer body with top/bottom chamfers (single connected solid)
        union() {
            // Middle prism
            linear_extrude(height = thickness - 2*chamfer_height, center = true)
                hex2d(R_outer);

            // Top chamfer frustum
            translate([0,0, (thickness/2 - chamfer_height/2)])
                linear_extrude(height = chamfer_height, center = true, scale = R_chamf/R_outer)
                    hex2d(R_outer);

            // Bottom chamfer frustum
            translate([0,0, -(thickness/2 - chamfer_height/2)])
                linear_extrude(height = chamfer_height, center = true, scale = R_chamf/R_outer)
                    hex2d(R_outer);
        }

        // Through-hole (ensure it fully cuts through with overlap)
        cylinder(d = hole_diameter, h = thickness + 2*eps, center = true);
    }
}

color("DimGray") nut_solid();