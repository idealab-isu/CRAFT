$fn = 96;

module motor_body(d=9, h=8){
    // Outrunner can body with slight rim details
    union(){
        cylinder(d=d, h=h, center=true);
        // top rim
        translate([0,0,h/2 - 0.35])
            cylinder(d=d+0.6, h=0.7, center=true);
        // bottom rim
        translate([0,0,-h/2 + 0.35])
            cylinder(d=d+0.6, h=0.7, center=true);
    }
}

module base_plate(d=10, h=1){
    cylinder(d=d, h=h, center=true);
}

module shaft(d=1, h=15.5){
    cylinder(d=d, h=h, center=true);
}

module bldc_outrunner(){
    // Place base at z=0, body above, shaft through center; overall centered near origin
    union(){
        // base plate thickness 1mm centered at z=0
        base_plate(d=10, h=1);

        // motor body height 8mm; sits on base (bottom at z=0.5)
        translate([0,0,0.5 + 8/2])
            motor_body(d=9, h=8);

        // shaft length 15.5mm, centered so it protrudes above body and slightly below base
        // center z such that top aligns with top of body + small protrusion
        // body top at z=0.5+8 = 8.5; make shaft top at z=8.5+3 = 11.5 => center at 11.5 - 15.5/2 = 3.75
        translate([0,0,3.75])
            shaft(d=1, h=15.5);
    }
}

bldc_outrunner();