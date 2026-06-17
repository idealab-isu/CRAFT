// Hex head screw: shaft d=5.0mm, shaft length=10mm
// Hex head: across flats=9.2mm, head height=3.65mm

shaft_d = 5.0;
shaft_l = 10.0;

head_af = 9.2;          // across flats
head_h  = 3.65;

overlap = 0.2;          // small overlap to guarantee a single connected solid

module screw_shaft(d=shaft_d, h=shaft_l) {
    cylinder(d=d, h=h, center=false, $fn=96);
}

module hex_head(af=head_af, h=head_h) {
    // For a regular hexagon made with $fn=6, cylinder(d=...) is across corners.
    // Convert across-flats (AF) to across-corners (AC): AC = AF / cos(30°)
    ac = af / cos(30);

    rotate([0, 0, 30])  // orient so flats are horizontal/vertical in standard views
        cylinder(d=ac, h=h, center=false, $fn=6);
}

module hex_head_screw() {
    union() {
        screw_shaft();
        translate([0, 0, shaft_l - overlap])
            hex_head();
    }
}

hex_head_screw();