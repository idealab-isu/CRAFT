$fn = 128;

// HT 90 pipe 500 mm (approximation)
// Dimensions in mm
pipe_length = 500;
outer_diameter = 90;
wall_thickness = 3.2;   // typical HT pipe wall thickness (approx)
inner_diameter = outer_diameter - 2*wall_thickness;

module ht_pipe(len=pipe_length, od=outer_diameter, id=inner_diameter) {
    difference() {
        cylinder(h=len, d=od, center=false);
        translate([0,0,-0.5])
            cylinder(h=len+1, d=id, center=false);
    }
}

ht_pipe();