$fn=64;

module sheet_acrylic(length=200, width=200, thickness=3, center=true) {
    cube([length, width, thickness], center=center);
}

sheet_acrylic();