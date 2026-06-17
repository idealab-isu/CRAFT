// Hex nut for 4.0mm screws, 8.1mm across flats, 3.2mm thick (plain hex nut)

// Parameters (fixed to requested dimensions)
thread_diameter_mm = 4.0;
across_flats_mm    = 8.1;
thickness_mm       = 3.2;

// Hole sizing
clearance_extra_mm = 0.3;   // typical clearance for printed parts
eps_mm             = 0.2;   // small extra for clean boolean cuts

$fn = 96;

// Regular hex profile defined by across-flats (AF)
// For a regular hex, circumradius R = AF / sqrt(3)
module hex_prism_by_af(af, h, center=true) {
    R = af / sqrt(3);
    linear_extrude(height=h, center=center)
        polygon(points=[
            [ R, 0],
            [ R/2,  R*sqrt(3)/2],
            [-R/2,  R*sqrt(3)/2],
            [-R, 0],
            [-R/2, -R*sqrt(3)/2],
            [ R/2, -R*sqrt(3)/2]
        ]);
}

module hex_nut(af, h, hole_d) {
    difference() {
        hex_prism_by_af(af, h, center=true);
        cylinder(d=hole_d, h=h + 2*eps_mm, center=true);
    }
}

// Final model: ONE connected solid (no washer/flange)
hex_nut(
    af = across_flats_mm,
    h  = thickness_mm,
    hole_d = thread_diameter_mm + clearance_extra_mm
);