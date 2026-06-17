$fn=96;

module pipe_segment(od=50, id=44, h=60){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.2, center=true);
    }
}

module socket(od=56, id=44, h=35){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.2, center=true);
    }
}

module tee_ht_50_40(){
    main_od = 50;
    main_id = 44;
    branch_od = 40;
    branch_id = 36;

    run_len = 140;
    branch_len = 90;

    socket_od_main = 56;
    socket_len_main = 35;

    socket_od_branch = 46;
    socket_len_branch = 30;

    union(){
        // Main run pipe
        pipe_segment(od=main_od, id=main_id, h=run_len);

        // Branch pipe (perpendicular)
        rotate([0,90,0]) pipe_segment(od=branch_od, id=branch_id, h=branch_len);

        // Main sockets at both ends
        translate([0,0, run_len/2 - socket_len_main/2]) socket(od=socket_od_main, id=main_id, h=socket_len_main);
        translate([0,0,-run_len/2 + socket_len_main/2]) socket(od=socket_od_main, id=main_id, h=socket_len_main);

        // Branch socket at end
        translate([branch_len/2 - socket_len_branch/2,0,0])
            rotate([0,90,0]) socket(od=socket_od_branch, id=branch_id, h=socket_len_branch);

        // Reinforcement collar at junction
        difference(){
            union(){
                cylinder(d=62, h=28, center=true);
                rotate([0,90,0]) cylinder(d=52, h=28, center=true);
            }
            union(){
                cylinder(d=main_id, h=run_len+0.4, center=true);
                rotate([0,90,0]) cylinder(d=branch_id, h=branch_len+0.4, center=true);
            }
        }
    }
}

difference(){
    tee_ht_50_40();
    // Ensure continuous internal passage at intersection
    union(){
        cylinder(d=44, h=200, center=true);
        rotate([0,90,0]) cylinder(d=36, h=200, center=true);
    }
}