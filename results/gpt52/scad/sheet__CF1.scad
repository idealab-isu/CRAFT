$fn=64;

module sheet_carbon_fiber(length=200, width=200, thickness=2, chamfer=0.5) {
    color([0.08,0.08,0.09])
    linear_extrude(height=thickness, center=true)
        offset(delta=-chamfer)
            offset(delta=chamfer)
                square([length, width], center=true);
}

sheet_carbon_fiber();