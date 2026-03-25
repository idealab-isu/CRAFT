$fn=96;

module bore_hole(d=5, h=30){
    cylinder(d=d, h=h, center=true);
}

module set_screw_hole(d=3, len=30){
    rotate([0,90,0]) cylinder(d=d, h=len, center=true);
}

module pulley_profile(od=40, width=16, hub_od=22, hub_width=22, groove_depth=3, rim_th=2){
    union(){
        // Main rim/body
        difference(){
            cylinder(d=od, h=width, center=true);
            // V-groove (approximated by subtracting two cones)
            union(){
                translate([0,0,0])
                    cylinder(d1=od-2*rim_th, d2=od-2*rim_th-2*groove_depth, h=width/2+0.2, center=true);
                translate([0,0,0])
                    cylinder(d1=od-2*rim_th-2*groove_depth, d2=od-2*rim_th, h=width/2+0.2, center=true);
            }
        }
        // Hub
        cylinder(d=hub_od, h=hub_width, center=true);
        // Flanges
        translate([0,0, width/2 - 1])
            cylinder(d=od, h=2, center=true);
        translate([0,0,-width/2 + 1])
            cylinder(d=od, h=2, center=true);
    }
}

module pulley(od=40, width=16, hub_od=22, hub_width=22, bore_d=5, set_screw_d=3){
    difference(){
        pulley_profile(od=od, width=width, hub_od=hub_od, hub_width=hub_width, groove_depth=3, rim_th=2);
        bore_hole(d=bore_d, h=hub_width+10);
        translate([0,0,0]) set_screw_hole(d=set_screw_d, len=hub_od+20);
    }
}

pulley(od=40, width=16, hub_od=22, hub_width=22, bore_d=5, set_screw_d=3);