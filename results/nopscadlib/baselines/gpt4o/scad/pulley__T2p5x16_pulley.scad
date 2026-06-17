module timing_pulley(teeth=16, pitch_diameter=12.16, belt_width=5, hub_diameter=8, hub_height=10) {
    tooth_height = 2;
    tooth_width = pitch_diameter * PI / teeth;
    pulley_height = belt_width + hub_height;
    
    module tooth() {
        translate([0, pitch_diameter / 2, 0])
        rotate([90, 0, 0])
        linear_extrude(height=belt_width)
        polygon(points=[[0, 0], [tooth_width / 2, tooth_height], [-tooth_width / 2, tooth_height]]);
    }
    
    union() {
        // Create the main pulley body
        cylinder(d=pitch_diameter, h=belt_width, $fn=64);
        
        // Add teeth around the pulley
        for (i = [0:teeth-1]) {
            rotate([0, 0, i * 360 / teeth])
            tooth();
        }
        
        // Add the hub
        translate([0, 0, -hub_height])
        cylinder(d=hub_diameter, h=pulley_height, $fn=64);
    }
}

timing_pulley();