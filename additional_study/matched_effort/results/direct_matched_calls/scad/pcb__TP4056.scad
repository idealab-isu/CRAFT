$fn = 64;

module battery_charger_module(len=26.2, wid=17.5, thick=1.0, corner_r=1.2) {
    corner_r2 = min(corner_r, min(len, wid)/2 - 0.01);
    linear_extrude(height=thick)
        offset(r=corner_r2)
            square([len - 2*corner_r2, wid - 2*corner_r2], center=true);
}

battery_charger_module();