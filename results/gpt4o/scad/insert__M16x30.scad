module threaded_heat_set_insert() {
    $fn = 64;
    outer_diameter = 30.0;
    length = 25.0;
    screw_diameter = 16.0;
    thread_height = 2.0;
    thread_pitch = 2.0;
    
    difference() {
        // Outer cylinder
        cylinder(d=outer_diameter, h=length, center=true);
        
        // Inner cylinder for screw
        translate([0, 0, -length/2])
            cylinder(d=screw_diameter, h=length + 2*thread_height, center=false);
        
        // Threading
        for (z = [-length/2 : thread_pitch : length/2]) {
            translate([0, 0, z])
                rotate([0, 0, 0])
                    cylinder(d1=outer_diameter, d2=outer_diameter - 2*thread_height, h=thread_height, center=false);
        }
    }
}

threaded_heat_set_insert();