$fn = 64;

module motor_driver_module(len=35.0, wid=32.0, th=1.6, corner_r=1.5) {
    corner_r = min(corner_r, min(len, wid)/2);

    linear_extrude(height=th)
        offset(r=corner_r)
            offset(delta=-corner_r)
                square([len, wid], center=false);
}

motor_driver_module();