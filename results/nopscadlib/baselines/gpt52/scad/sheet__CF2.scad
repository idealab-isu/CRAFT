$fn=64;

module carbon_fiber_sheet(length=200, width=200, thickness=2, weave_pitch=6, weave_depth=0.15) {
    difference() {
        translate([0,0,0]) cube([length, width, thickness], center=true);

        for (x = [-length/2 : weave_pitch : length/2]) {
            translate([x, 0, thickness/2 - weave_depth/2])
                cube([weave_pitch/2, width+2, weave_depth], center=true);
        }

        for (y = [-width/2 : weave_pitch : width/2]) {
            translate([0, y, thickness/2 - weave_depth/2])
                cube([length+2, weave_pitch/2, weave_depth], center=true);
        }
    }
}

carbon_fiber_sheet();