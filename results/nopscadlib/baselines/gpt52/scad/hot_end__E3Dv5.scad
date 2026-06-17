$fn=96;

total_len = 70.0;
barrel_d = 3.7;
filament_d = 1.75;

module axial_hole(h=1, d=1){
    translate([0,0,-0.01]) cylinder(h=h+0.02, d=d, center=false);
}

module hotend(){
    union(){
        // Top heatsink (approx)
        translate([0,0,52])
        difference(){
            cylinder(h=18, d=16, center=false);
            axial_hole(h=18, d=filament_d+0.25);
        }

        // Heatsink fins
        for(z=[52.5:2.5:68.0]){
            translate([0,0,z])
            difference(){
                cylinder(h=1.2, d=22, center=false);
                axial_hole(h=1.2, d=filament_d+0.25);
            }
        }

        // Heatbreak / barrel
        translate([0,0,30])
        difference(){
            cylinder(h=22, d=barrel_d, center=false);
            axial_hole(h=22, d=filament_d+0.15);
        }

        // Heater block
        translate([0,0,18])
        difference(){
            translate([-10,-8,0]) cube([20,16,12], center=false);
            translate([0,0,0]) rotate([90,0,0]) translate([0,0,-9]) cylinder(h=18, d=6.2, center=false);
            translate([0,0,0]) axial_hole(h=12, d=filament_d+0.15);
        }

        // Nozzle
        translate([0,0,0])
        difference(){
            union(){
                cylinder(h=6, d=7, center=false);
                translate([0,0,6]) cylinder(h=12, d1=7, d2=1.0, center=false);
            }
            axial_hole(h=18, d=0.4);
        }
    }
}

scale([1,1,total_len/70.0]) hotend();