$fn=64;

module seg(len, w, h){
    translate([0,0,0]) cube([len, w, h], center=false);
}

module stepped_bar(total_len=0.2, base_w=0.06, base_h=0.06){
    // Build along X, centered at origin overall
    // Segment plan (lengths sum to total_len):
    // 0.03 base, 0.02 thick, 0.04 base, 0.03 thick, 0.05 base, 0.03 thick
    l1=0.03; l2=0.02; l3=0.04; l4=0.03; l5=0.05; l6=0.03;
    w2=0.12; h2=0.12;
    w4=0.10; h4=0.10;
    w6=0.14; h6=0.14;

    union(){
        translate([-total_len/2, -base_w/2, -base_h/2]) seg(l1, base_w, base_h);
        translate([-total_len/2 + l1, -w2/2, -h2/2]) seg(l2, w2, h2);
        translate([-total_len/2 + l1 + l2, -base_w/2, -base_h/2]) seg(l3, base_w, base_h);
        translate([-total_len/2 + l1 + l2 + l3, -w4/2, -h4/2]) seg(l4, w4, h4);
        translate([-total_len/2 + l1 + l2 + l3 + l4, -base_w/2, -base_h/2]) seg(l5, base_w, base_h);
        translate([-total_len/2 + l1 + l2 + l3 + l4 + l5, -w6/2, -h6/2]) seg(l6, w6, h6);
    }
}

stepped_bar();