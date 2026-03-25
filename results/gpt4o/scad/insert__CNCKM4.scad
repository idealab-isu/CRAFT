module threaded_insert() {
    $fn = 64;
    outer_diameter = 4.0;
    length = 6.3;
    thread_diameter = 4.0;
    thread_pitch = 0.7; // typical for M4 screws
    num_threads = floor(length / thread_pitch);

    difference() {
        cylinder(h = length, d = outer_diameter, center = true);
        translate([0, 0, -length/2])
            cylinder(h = length, d = thread_diameter, center = false);
    }
}

threaded_insert();