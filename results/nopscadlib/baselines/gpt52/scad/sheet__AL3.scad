$fn=64;

module tooling_plate(length=200, width=150, thickness=10, corner_r=6) {
    corner_r2 = min(corner_r, min(length, width)/2);
    translate([0,0,thickness/2])
    linear_extrude(height=thickness, center=true)
        offset(r=corner_r2)
            square([length-2*corner_r2, width-2*corner_r2], center=true);
}

tooling_plate();