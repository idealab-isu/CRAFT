$fn=64;

module tooling_plate(length=300, width=200, thickness=10, corner_r=10) {
    corner_r2 = min(corner_r, min(length, width)/2);
    translate([-length/2, -width/2, -thickness/2])
    linear_extrude(height=thickness)
    offset(r=corner_r2)
    offset(delta=-corner_r2)
    square([length, width], center=false);
}

tooling_plate(length=300, width=200, thickness=10, corner_r=10);