$fn=96;

module bore_hole(d=8, h=30){
    cylinder(d=d, h=h, center=true);
}

module set_screw_hole(d=3, len=40, z=0){
    translate([0,0,z])
        rotate([0,90,0])
            cylinder(d=d, h=len, center=true);
}

module hub(od=24, w=18){
    cylinder(d=od, h=w, center=true);
}

module pulley_rim(od=60, w=18){
    cylinder(d=od, h=w, center=true);
}

module v_groove(od=60, w=18, depth=6, angle=40){
    // Approximated V-groove by subtracting two opposing cones
    // Cones meet near the center to form a V profile
    cone_h = w*1.2;
    top_d = od + depth*2;
    mid_d = od - depth*2;
    union(){
        translate([0,0,0])
            cylinder(d=mid_d, h=w+0.2, center=true);
        translate([0,0, w/2])
            cylinder(d1=top_d, d2=mid_d, h=cone_h, center=false);
        translate([0,0,-w/2-cone_h])
            cylinder(d1=mid_d, d2=top_d, h=cone_h, center=false);
    }
}

module spokes(count=6, rim_od=60, hub_od=24, w=18, spoke_th=6){
    r1 = hub_od/2 + 1;
    r2 = rim_od/2 - 6;
    for(i=[0:count-1]){
        rotate([0,0,360*i/count])
            translate([(r1+r2)/2,0,0])
                cube([r2-r1, spoke_th, w], center=true);
    }
}

module pulley(){
    rim_od = 60;
    width  = 18;
    hub_od = 24;
    bore_d = 8;

    difference(){
        union(){
            // Rim
            pulley_rim(od=rim_od, w=width);

            // Hub
            hub(od=hub_od, w=width);

            // Spokes
            spokes(count=6, rim_od=rim_od, hub_od=hub_od, w=width, spoke_th=6);
        }

        // V-groove cut
        v_groove(od=rim_od, w=width, depth=6, angle=40);

        // Bore
        bore_hole(d=bore_d, h=width+10);

        // Set screw hole (radial)
        set_screw_hole(d=3, len=rim_od+20, z=0);
    }
}

pulley();