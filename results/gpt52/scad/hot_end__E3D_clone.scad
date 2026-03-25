$fn=96;

filament_d = 1.75;
total_len = 66.0;

barrel_d = 6.8;
barrel_len = 30.0;

heatsink_d = 22.0;
heatsink_len = 25.0;

heater_block_w = 20.0;
heater_block_d = 16.0;
heater_block_h = 12.0;

nozzle_len = total_len - (heatsink_len + barrel_len + heater_block_h);
nozzle_len2 = max(nozzle_len, 6.0);

module fin_stack(od=22, id=6.8, len=25, fin_th=1.2, gap=1.2) {
    n = floor((len + gap) / (fin_th + gap));
    union() {
        for (i = [0 : n-1]) {
            z0 = -len/2 + i*(fin_th+gap) + fin_th/2;
            translate([0,0,z0])
                difference() {
                    cylinder(d=od, h=fin_th, center=true);
                    cylinder(d=id, h=fin_th+0.4, center=true);
                }
        }
        cylinder(d=id, h=len, center=true);
    }
}

module heater_block(w=20, d=16, h=12, bore_d=6.8, filament_d=1.75) {
    difference() {
        cube([w,d,h], center=true);
        rotate([90,0,0]) cylinder(d=bore_d, h=d+0.6, center=true);
        cylinder(d=filament_d, h=h+0.6, center=true);
        translate([0,0,-h*0.15]) cylinder(d=3.2, h=h+0.6, center=true);
    }
}

module nozzle(len=12, top_d=6.8, tip_d=1.2, filament_d=1.75) {
    difference() {
        union() {
            cylinder(d=top_d, h=len*0.35, center=false);
            translate([0,0,len*0.35])
                cylinder(d1=top_d, d2=tip_d, h=len*0.65, center=false);
        }
        translate([0,0,-0.2]) cylinder(d=filament_d, h=len+0.4, center=false);
        translate([0,0,len*0.78]) cylinder(d1=filament_d, d2=0.4, h=len*0.22+0.4, center=false);
    }
}

module hotend() {
    z0 = -total_len/2;

    z_heatsink = z0 + heatsink_len/2;
    z_barrel   = z0 + heatsink_len + barrel_len/2;
    z_block    = z0 + heatsink_len + barrel_len + heater_block_h/2;
    z_nozzle   = z0 + heatsink_len + barrel_len + heater_block_h;

    difference() {
        union() {
            translate([0,0,z_heatsink]) fin_stack(od=heatsink_d, id=barrel_d, len=heatsink_len, fin_th=1.2, gap=1.2);
            translate([0,0,z_barrel]) cylinder(d=barrel_d, h=barrel_len, center=true);
            translate([0,0,z_block]) heater_block(w=heater_block_w, d=heater_block_d, h=heater_block_h, bore_d=barrel_d, filament_d=filament_d);
            translate([0,0,z_nozzle]) nozzle(len=nozzle_len2, top_d=barrel_d, tip_d=1.2, filament_d=filament_d);
        }
        translate([0,0,0]) cylinder(d=filament_d, h=total_len+2, center=true);
    }
}

hotend();