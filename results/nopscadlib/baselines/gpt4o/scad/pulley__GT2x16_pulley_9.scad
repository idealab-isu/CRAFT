module timing_pulley(teeth=16, pitch_diameter=9.65, belt_width=5, hub_diameter=6, hub_height=10) {
    tooth_height = 2;
    tooth_width = pitch_diameter * PI / teeth;
    pulley_radius = pitch_diameter / 2;
    
    module tooth() {
        translate([0, pulley_radius, 0])
        rotate([90, 0, 0])
        linear_extrude(height=belt_width)
        polygon(points=[[0, 0], [tooth_width / 2, tooth_height], [-tooth_width / 2, tooth_height]]);
    }
    
    module pulley_body() {
        difference() {
            cylinder(h=belt_width, r=pulley_radius, $fn=64);
            translate([0, 0, -1])
            cylinder(h=belt_width + 2, r=hub_diameter / 2, $fn=64);
        }
    }
    
    module hub() {
        translate([0, 0, -hub_height])
        cylinder(h=hub_height, r=hub_diameter / 2, $fn=64);
    }
    
    union() {
        pulley_body();
        hub();
        for (i = [0:teeth-1]) {
            rotate([0, 0, i * 360 / teeth])
            tooth();
        }
    }
}

timing_pulley();