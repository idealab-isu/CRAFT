$fn=64;

L = 0.1;
W = 0.1;
H = 0.1;

wedge_len = 0.04;
body_len  = L - wedge_len;

clevis_len = 0.03;
arm_thk = 0.02;
gap_w = 0.03;
arm_h = 0.06;

module wedge_body(len_body, len_wedge, w, h){
    union(){
        translate([-(L/2) + len_wedge + len_body/2, 0, 0])
            cube([len_body, w, h], center=true);

        translate([-(L/2) + len_wedge, 0, 0])
            linear_extrude(height=h, center=true)
                polygon(points=[
                    [0, -w/2],
                    [0,  w/2],
                    [-len_wedge, 0]
                ]);
    }
}

module clevis_feature(len_c, w_total, h_total, arm_t, gap){
    difference(){
        union(){
            translate([L/2 - len_c/2, 0, 0])
                cube([len_c, w_total, h_total], center=true);

            translate([L/2 - len_c/2, 0, h_total/2])
                rotate([0,90,0])
                    cylinder(h=len_c, r=w_total/2, center=true);
        }

        translate([L/2 - len_c/2, 0, 0])
            cube([len_c+0.002, gap, h_total+0.002], center=true);

        translate([L/2 - len_c/2, 0, h_total/2])
            rotate([0,90,0])
                cylinder(h=len_c+0.002, r=gap/2, center=true);

        translate([L/2 - len_c/2, 0, 0])
            rotate([0,90,0])
                cylinder(h=len_c+0.004, r=0.012, center=true);
    }
}

union(){
    wedge_body(body_len, wedge_len, W, H);

    translate([0,0,0])
        clevis_feature(clevis_len, W, arm_h, arm_thk, gap_w);
}