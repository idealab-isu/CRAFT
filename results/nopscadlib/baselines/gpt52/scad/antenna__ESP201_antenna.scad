$fn=96;

module rounded_cylinder(h=10, r=5, fillet=1){
    union(){
        cylinder(h=h-2*fillet, r=r, center=true);
        translate([0,0,(h/2)-fillet]) sphere(r=fillet);
        translate([0,0,-(h/2)+fillet]) sphere(r=fillet);
    }
}

module antenna_base(base_d=40, base_h=10, foot_d=46, foot_h=2){
    union(){
        translate([0,0,-(base_h/2 + foot_h/2)]) cylinder(h=foot_h, r=foot_d/2, center=true);
        translate([0,0,-base_h/2]) cylinder(h=base_h, r=base_d/2, center=true);
        translate([0,0,-base_h/2 + base_h/2]) cylinder(h=2, r1=base_d/2, r2=(base_d/2)*0.85, center=true);
    }
}

module antenna_mast(mast_h=140, mast_r=2.2){
    union(){
        translate([0,0,mast_h/2]) cylinder(h=mast_h, r=mast_r, center=true);
        translate([0,0,mast_h]) sphere(r=mast_r*1.15);
    }
}

module antenna_coil(turns=7, coil_r=6.5, wire_r=1.0, pitch=6.0){
    linear_extrude(height=turns*pitch, twist=turns*360, center=false, convexity=10)
        translate([coil_r,0,0]) circle(r=wire_r);
}

module antenna_radials(count=4, len=55, r=1.2, angle_down=25){
    for(i=[0:count-1]){
        rotate([0,0,i*360/count])
            rotate([0,angle_down,0])
                translate([len/2,0,0])
                    cylinder(h=len, r=r, center=true);
    }
}

module antenna(){
    base_d=40;
    base_h=10;
    foot_d=46;
    foot_h=2;

    mast_h=150;
    mast_r=2.2;

    coil_turns=7;
    coil_r=6.5;
    wire_r=1.0;
    pitch=6.0;

    union(){
        antenna_base(base_d=base_d, base_h=base_h, foot_d=foot_d, foot_h=foot_h);

        translate([0,0,0])
            antenna_radials(count=4, len=55, r=1.2, angle_down=25);

        translate([0,0,base_h/2])
            antenna_mast(mast_h=mast_h, mast_r=mast_r);

        translate([0,0,base_h/2 + 18])
            antenna_coil(turns=coil_turns, coil_r=coil_r, wire_r=wire_r, pitch=pitch);

        translate([0,0,base_h/2 + 18 + coil_turns*pitch + 10])
            rounded_cylinder(h=18, r=3.2, fillet=1.2);
    }
}

translate([0,0,-6]) antenna();