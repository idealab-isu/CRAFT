$fn=64;

module sheet_silicone(length=200, width=200, thickness=2, corner_r=10){
    corner = min(corner_r, min(length, width)/2);
    linear_extrude(height=thickness, center=true)
        offset(r=corner)
            square([length-2*corner, width-2*corner], center=true);
}

sheet_silicone();