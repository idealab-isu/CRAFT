$fn = 160;

// Threaded heat-set insert (visual approximation with knurl + internal hole)
// Target: OD 3.0mm, length 4.6mm, for M3 screw

od = 3.0;
len = 4.6;

// M3 internal thread minor diameter is ~2.4–2.6mm; use a printable/visual bore
id = 2.5;

// Lead-in chamfers
ch = 0.35;

// Knurling (simple axial grooves)
knurl_count = 18;      // number of grooves around
knurl_depth = 0.18;    // radial depth of grooves
knurl_w = 0.35;        // groove width (tangential)
knurl_h = len - 2*ch;  // keep chamfers clean

eps = 0.03;

module insert_body() {
    union() {
        // Main cylinder
        cylinder(h=len, d=od, center=true);

        // Chamfers (slight overlap to ensure connectivity)
        translate([0,0,-len/2 + ch/2 - eps/2])
            cylinder(h=ch+eps, d1=od-2*ch, d2=od, center=true);

        translate([0,0, len/2 - ch/2 + eps/2])
            cylinder(h=ch+eps, d1=od, d2=od-2*ch, center=true);
    }
}

module knurl_cutters() {
    // Grooves are subtracted from the outer surface
    for (i = [0:knurl_count-1]) {
        rotate([0,0,i*360/knurl_count])
            translate([od/2 - knurl_depth/2, 0, 0])
                cube([knurl_depth + 2*eps, knurl_w, knurl_h + 2*eps], center=true);
    }
}

difference() {
    // Outer shape with knurling
    difference() {
        insert_body();
        knurl_cutters();
    }

    // Internal bore (through), extended to guarantee clean subtraction
    cylinder(h=len + 4*eps, d=id, center=true);
}