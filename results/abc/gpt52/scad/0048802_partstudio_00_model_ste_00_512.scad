$fn=64;

L = 0.3;
W_end = 0.1;
H = 0.1;

L_end = 0.07;
L_mid = 0.10;
L_web = (L - 2*L_end - L_mid)/2;

W_web = 0.04;
W_mid = 0.07;

module seg(len, wid, hgt){
    cube([len, wid, hgt], center=true);
}

module dumbbell_bar(){
    union(){
        translate([-(L/2 - L_end/2), 0, 0]) seg(L_end, W_end, H);
        translate([ (L/2 - L_end/2), 0, 0]) seg(L_end, W_end, H);

        translate([-(L_mid/2 + L_web/2), 0, 0]) seg(L_web, W_web, H);
        translate([ (L_mid/2 + L_web/2), 0, 0]) seg(L_web, W_web, H);

        seg(L_mid, W_mid, H);
    }
}

dumbbell_bar();