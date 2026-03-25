$fn=64;

module dibond_sheet(length=300, width=200, thickness=3) {
    translate([-length/2, -width/2, -thickness/2])
        cube([length, width, thickness], center=false);
}

dibond_sheet();