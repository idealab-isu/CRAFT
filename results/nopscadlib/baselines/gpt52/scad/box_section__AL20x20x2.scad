$fn=64;

module box_section_20x20x2(len=100, outer=20, wall=2) {
    difference() {
        cube([outer, outer, len], center=true);
        cube([outer-2*wall, outer-2*wall, len+0.2], center=true);
    }
}

box_section_20x20x2(len=100, outer=20, wall=2);