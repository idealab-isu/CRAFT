module knob() {
    sphere_radius = 3.4;
    cylinder_height = 3.1;
    cylinder_radius = 1.5;
    
    translate([0, 0, cylinder_height])
    sphere(r=sphere_radius, $fn=64);
    
    translate([0, 0, 0])
    cylinder(h=cylinder_height, r=cylinder_radius, $fn=64);
}

knob();