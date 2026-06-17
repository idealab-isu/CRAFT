$fn=64;

module sheet_mild_steel(length=200, width=200, thickness=3) {
    translate([-length/2, -width/2, -thickness/2])
        cube([length, width, thickness], center=false);
}

sheet_mild_steel();