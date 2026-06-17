module pointed_connector() {
    // Main body dimensions
    length = 24.5;
    width = 7.8;
    height = 4.5;
    slot_length = 20;
    slot_width = 3;
    notch_depth = 0.5;
    notch_width = 2;
    tip_length = 2.5;
    
    // Create the main body with conical tips
    difference() {
        union() {
            // Central body
            translate([0, 0, -height/2])
                cube([length - 2*tip_length, width, height], center=true);
            
            // Conical tips
            translate([-(length/2 - tip_length), 0, 0])
                rotate([90, 0, 0])
                cylinder(h=tip_length, r1=width/2, r2=0, $fn=64);
            translate([(length/2 - tip_length), 0, 0])
                rotate([90, 0, 0])
                cylinder(h=tip_length, r1=width/2, r2=0, $fn=64);
        }
        
        // Central slot (obround)
        translate([0, 0, -height])
            rotate([90, 0, 0])
            offset(r=slot_width/2)
            translate([-slot_length/2, -slot_width/2])
            square([slot_length, slot_width], center=false);
        
        // Side notches
        translate([0, width/2, 0])
            cube([notch_width, notch_depth, height], center=true);
        translate([0, -width/2, 0])
            cube([notch_width, notch_depth, height], center=true);
    }
}

pointed_connector();