module threaded_heat_set_insert() {
    $fn = 64;
    outer_diameter = 5.8;
    length = 4.6;
    inner_diameter = 2.5;
    thread_height = 0.5;
    thread_pitch = 0.8;
    
    difference() {
        cylinder(d=outer_diameter, h=length, center=true);
        translate([0, 0, -length/2])
            cylinder(d=inner_diameter, h=length, center=false);
        for (z = [-length/2 : thread_pitch : length/2]) {
            translate([0, 0, z])
                rotate([0, 0, 0])
                    cylinder(d=outer_diameter + thread_height, h=thread_height, center=true);
        }
    }
}

threaded_heat_set_insert();