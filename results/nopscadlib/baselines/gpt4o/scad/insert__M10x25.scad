module threaded_heat_set_insert() {
    $fn = 64;
    outer_diameter = 25.0;
    length = 18.5;
    screw_diameter = 10.0;
    thread_height = 1.5;
    thread_pitch = 2.0;
    
    difference() {
        // Outer cylinder
        cylinder(d=outer_diameter, h=length, center=true);
        
        // Inner screw hole
        translate([0, 0, -length/2])
            cylinder(d=screw_diameter, h=length + 2, center=false);
        
        // Thread pattern
        for (z = [-length/2 : thread_pitch : length/2]) {
            translate([0, 0, z])
                rotate([0, 0, 0])
                    cylinder(d1=outer_diameter, d2=outer_diameter - thread_height, h=thread_pitch, center=false);
        }
    }
}

threaded_heat_set_insert();