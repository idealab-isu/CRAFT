$fn=64;

module u_channel_bracket(
    size_x=31.8,
    size_y=31.8,
    size_z=15.8,
    web=6.0,
    jaw=6.0,
    lug_x=4.0,
    lug_y=10.0,
    lug_z=3.0,
    lug_offset_y=6.0
){
    inner_x = size_x - web;
    inner_y = size_y - 2*jaw;

    difference(){
        union(){
            cube([size_x, size_y, size_z], center=true);

            translate([ size_x/2 + lug_x/2, lug_offset_y, 0 ])
                cube([lug_x, lug_y, lug_z], center=true);
        }

        translate([ web/2, 0, 0 ])
            cube([inner_x, inner_y, size_z+0.2], center=true);
    }
}

u_channel_bracket();