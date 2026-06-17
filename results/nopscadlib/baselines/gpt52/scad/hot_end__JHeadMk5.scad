$fn=96;

filament_d = 1.75;
total_len = 51.2;
barrel_d = 4.75;

module filament_path(h=total_len+2, d=filament_d){
    translate([0,0,-h/2]) cylinder(h=h, d=d);
}

module heater_block(size=[16,16,12]){
    translate([-size[0]/2, -size[1]/2, -size[2]/2]) cube(size);
}

module nozzle(nozzle_len=12, base_d=7, tip_d=1.0, tip_len=2.0){
    union(){
        translate([0,0,-nozzle_len/2])
            cylinder(h=nozzle_len-tip_len, d1=base_d, d2=3.0);
        translate([0,0,(-nozzle_len/2)+(nozzle_len-tip_len)])
            cylinder(h=tip_len, d1=3.0, d2=tip_d);
    }
}

module heatsink(fin_count=7, fin_d=16, fin_t=1.2, gap=1.0, core_d=8, core_h=18){
    union(){
        translate([0,0,core_h/2]) cylinder(h=core_h, d=core_d);
        for(i=[0:fin_count-1]){
            z = i*(fin_t+gap) + fin_t/2;
            translate([0,0,z]) cylinder(h=fin_t, d=fin_d);
        }
    }
}

module hotend(){
    heatsink_h = 18;
    heater_h = 12;
    nozzle_h = 12;
    barrel_h = total_len - (heatsink_h + heater_h + nozzle_h);

    z0 = -total_len/2;

    difference(){
        union(){
            translate([0,0,z0 + heatsink_h/2])
                heatsink(fin_count=7, fin_d=16, fin_t=1.2, gap=1.0, core_d=8, core_h=heatsink_h);

            translate([0,0,z0 + heatsink_h + barrel_h/2])
                cylinder(h=barrel_h, d=barrel_d);

            translate([0,0,z0 + heatsink_h + barrel_h + heater_h/2])
                heater_block([16,16,heater_h]);

            translate([0,0,z0 + heatsink_h + barrel_h + heater_h + nozzle_h/2])
                nozzle(nozzle_len=nozzle_h, base_d=7, tip_d=1.0, tip_len=2.0);
        }

        filament_path(h=total_len+4, d=filament_d);

        translate([0,0,z0 + heatsink_h + barrel_h + heater_h/2])
            rotate([90,0,0]) cylinder(h=22, d=6);

        translate([0,0,z0 + heatsink_h + barrel_h + heater_h/2])
            rotate([0,90,0]) cylinder(h=22, d=3);
    }
}

hotend();