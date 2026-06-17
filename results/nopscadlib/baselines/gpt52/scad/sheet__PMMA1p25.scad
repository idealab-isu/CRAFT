$fn=64;

module sheet_acrylic(length=200, width=200, thickness=3, center_xy=true) {
    translate([0,0,0])
        cube([length, width, thickness], center=center_xy);
}

sheet_acrylic(length=200, width=200, thickness=3, center_xy=true);