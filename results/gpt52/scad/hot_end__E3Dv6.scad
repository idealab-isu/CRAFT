$fn=96;

filament_d = 1.75;
total_len = 62.0;

barrel_d = 3.7;
barrel_len = 30.0;

heater_block_w = 16.0;
heater_block_d = 16.0;
heater_block_h = 12.0;

nozzle_len = total_len - barrel_len - heater_block_h; // 20.0
nozzle_hex_h = 6.0;
nozzle_hex_af = 7.0; // across flats
nozzle_tip_len = nozzle_len - nozzle_hex_h; // 14.0
nozzle_tip_d1 = 6.0;
nozzle_tip_d2 = 1.0;

heatbreak_len = 6.0;
heatbreak_d = 2.0;

module hex_prism(af=7, h=6){
    r = af / sqrt(3);
    cylinder(h=h, r=r, $fn=6);
}

module heater_block(w=16, d=16, h=12){
    translate([-w/2, -d/2, 0]) cube([w, d, h], center=false);
}

module nozzle(){
    union(){
        translate([0,0,0]) cylinder(h=nozzle_tip_len, d1=nozzle_tip_d1, d2=nozzle_tip_d2);
        translate([0,0,nozzle_tip_len]) hex_prism(af=nozzle_hex_af, h=nozzle_hex_h);
    }
}

module hotend_solid(){
    union(){
        translate([0,0,0]) nozzle();
        translate([0,0,nozzle_len]) heater_block(heater_block_w, heater_block_d, heater_block_h);
        translate([0,0,nozzle_len + heater_block_h]) cylinder(h=barrel_len, d=barrel_d);
    }
}

module filament_path(){
    // Through entire hotend
    translate([0,0,-0.5]) cylinder(h=total_len+1.0, d=filament_d);
    // Heatbreak section (slightly larger bore)
    translate([0,0,nozzle_len + heater_block_h - heatbreak_len]) cylinder(h=heatbreak_len, d=2.0);
    // Nozzle internal taper near tip
    translate([0,0,0]) cylinder(h=3.0, d1=2.0, d2=0.4);
}

difference(){
    translate([0,0,-total_len/2]) hotend_solid();
    translate([0,0,-total_len/2]) filament_path();
}