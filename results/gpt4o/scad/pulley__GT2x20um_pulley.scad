module timing_pulley(teeth=20, pitch_diameter=12.22, belt_width=5, hub_diameter=8, hub_height=10) {
    tooth_height = 2;
    tooth_width = pitch_diameter * PI / teeth;
    pulley_radius = pitch_diameter / 2;
    
    module tooth() {
        translate([0, pulley_radius, 0])
        rotate([90, 0, 0])
        linear_extrude(height=belt_width)
        polygon(points=[[0, 0], [tooth_width / 2, tooth_height], [-tooth_width / 2, tooth_height]]);
    }
    
    union() {
        // Create the main pulley body
        cylinder(h=belt_width, r=pulley_radius, $fn=64);
        
        // Add teeth around the pulley
        for (i = [0:teeth-1]) {
            rotate([0, 0, i * 360 / teeth])
            tooth();
        }
        
        // Add the hub
        translate([0, 0, -hub_height])
        cylinder(h=hub_height + belt_width, r=hub_diameter / 2, $fn=64);
    }
}

timing_pulley();