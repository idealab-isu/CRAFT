$fn = 64;

module dcdc_power_converter_module(
    length = 78.0,
    width  = 47.0,
    thickness = 1.6,
    corner_radius = 2.0
){
    corner_radius = min(corner_radius, min(length, width)/2);

    linear_extrude(height = thickness)
        offset(r = corner_radius)
            square([length - 2*corner_radius, width - 2*corner_radius], center = true);
}

dcdc_power_converter_module();