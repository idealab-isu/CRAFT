$fn=64;

module rounded_box(size=[1.4,1.0,2.6], r=0.18){
    x=size[0]; y=size[1]; z=size[2];
    r2=min(r, x/2-0.001, y/2-0.001);
    linear_extrude(height=z, center=true)
        offset(r=r2)
            square([x-2*r2, y-2*r2], center=true);
}

module latch_boss(boss=[0.28,0.42,0.70], r=0.10){
    bx=boss[0]; by=boss[1]; bz=boss[2];
    r2=min(r, bx/2-0.001, by/2-0.001);
    linear_extrude(height=bz, center=true)
        offset(r=r2)
            square([bx-2*r2, by-2*r2], center=true);
}

module tab_with_hole(tab_len=0.55, tab_w=0.55, tab_t=0.55, neck_len=0.18, neck_w=0.30, hole_d=0.22, r=0.12){
    union(){
        translate([0,0,(2.6/2) + neck_len/2])
            linear_extrude(height=neck_len, center=true)
                offset(r=min(0.08, neck_w/2-0.001, 1.0))
                    square([neck_w-2*min(0.08, neck_w/2-0.001, 1.0), 0.55-2*min(0.08, neck_w/2-0.001, 1.0)], center=true);

        translate([0,0,(2.6/2) + neck_len + tab_len/2])
            difference(){
                linear_extrude(height=tab_len, center=true)
                    offset(r=min(r, tab_w/2-0.001, tab_t/2-0.001))
                        square([tab_w-2*min(r, tab_w/2-0.001, tab_t/2-0.001), tab_t-2*min(r, tab_w/2-0.001, tab_t/2-0.001)], center=true);
                rotate([90,0,0])
                    cylinder(d=hole_d, h=tab_t+0.6, center=true);
            }
    }
}

module housing(){
    main_size=[1.4,1.0,2.6];
    main_r=0.18;

    boss_size=[0.28,0.42,0.70];
    boss_r=0.10;

    notch_size=[0.30,0.60,0.22];
    notch_r=0.08;

    difference(){
        union(){
            rounded_box(main_size, main_r);

            translate([ (main_size[0]/2) + boss_size[0]/2 - 0.02, 0, 0.10 ])
                latch_boss(boss_size, boss_r);

            tab_with_hole(
                tab_len=0.55,
                tab_w=0.55,
                tab_t=0.55,
                neck_len=0.18,
                neck_w=0.30,
                hole_d=0.22,
                r=0.12
            );
        }

        translate([ -(main_size[0]/2) + notch_size[0]/2 - 0.02, 0, -0.10 ])
            linear_extrude(height=notch_size[2], center=true)
                offset(r=min(notch_r, notch_size[0]/2-0.001, notch_size[1]/2-0.001))
                    square([notch_size[0]-2*min(notch_r, notch_size[0]/2-0.001, notch_size[1]/2-0.001),
                            notch_size[1]-2*min(notch_r, notch_size[0]/2-0.001, notch_size[1]/2-0.001)], center=true);
    }
}

housing();