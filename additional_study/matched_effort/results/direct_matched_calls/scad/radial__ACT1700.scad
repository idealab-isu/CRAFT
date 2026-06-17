$fn=128;

module radial(d=[10.8, 10.8, 5.3, 1]) {
    // d = [outer_diameter, inner_diameter, height, wall_thickness]
    od = d[0];
    id = d[1];
    h  = d[2];
    t  = d[3];

    // If inner diameter equals outer diameter, interpret as a ring with thickness t
    inner_d = (id >= od) ? max(0, od - 2*t) : id;

    difference() {
        cylinder(d=od, h=h);
        translate([0,0,-0.01]) cylinder(d=inner_d, h=h+0.02);
    }
}

radial([10.8, 10.8, 5.3, 1]);