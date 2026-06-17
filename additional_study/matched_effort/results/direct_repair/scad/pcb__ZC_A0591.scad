$fn = 64;

module motor_driver_module(length=35.0, width=32.0, thickness=1.6, corner_r=1.5) {
    corner_r = min(corner_r, min(length, width)/2 - 0.01);

    linear_extrude(height=thickness)
        offset(r=corner_r)
            square([length - 2*corner_r, width - 2*corner_r], center=true);
}

motor_driver_module();