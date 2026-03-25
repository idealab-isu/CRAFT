$fn=64;

module foil_tape_sheet(length=120, width=60, thickness=0.08, corner_r=2, adhesive_thickness=0.02) {
    union() {
        // Aluminum foil layer
        color([0.75,0.75,0.78])
        linear_extrude(height=thickness, center=true)
            offset(r=corner_r)
                square([length-2*corner_r, width-2*corner_r], center=true);

        // Adhesive layer (slightly darker)
        translate([0,0,-(thickness+adhesive_thickness)/2])
        color([0.55,0.55,0.58])
        linear_extrude(height=adhesive_thickness, center=true)
            offset(r=corner_r)
                square([length-2*corner_r, width-2*corner_r], center=true);
    }
}

foil_tape_sheet();