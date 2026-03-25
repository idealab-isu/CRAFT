module timing_pulley(teeth=80, pitch_diameter=50.42, belt_width=10, tooth_height=2, hub_diameter=20, hub_height=15) {
    tooth_angle = 360 / teeth;
    tooth_width = pitch_diameter * PI / teeth;
    
    module tooth() {
        translate([pitch_diameter / 2, 0, 0])
        rotate([0, 0, -tooth_angle / 2])
        linear_extrude(height=belt_width)
        polygon(points=[[0, 0], [tooth_width / 2, tooth_height], [-tooth_width / 2, tooth_height]]);
    }
    
    module pulley_teeth() {
        for (i = [0:teeth-1]) {
            rotate([0, 0, i * tooth_angle])
            tooth();
        }
    }
    
    module hub() {
        cylinder(d=hub_diameter, h=hub_height, $fn=64);
    }
    
    module belt_surface() {
        cylinder(d=pitch_diameter, h=belt_width, $fn=64);
    }
    
    union() {
        pulley_teeth();
        translate([0, 0, -hub_height])
        hub();
        belt_surface();
    }
}

timing_pulley();