$fn=64;

plate_len = 0.4;
plate_w   = 0.08;
plate_t   = 0.02;

stud_count = 5;
stud_d     = 0.03;
stud_h     = 0.012;

module rounded_stud(d, h){
    r = d/2;
    union(){
        cylinder(h=max(h - r, 0), r=r);
        translate([0,0,max(h - r, 0)]) sphere(r=r);
    }
}

module stud_row(n, len, d, h){
    if(n <= 1){
        translate([0,0,0]) rounded_stud(d, h);
    } else {
        pitch = len/(n-1);
        for(i=[0:n-1]){
            translate([-len/2 + i*pitch, 0, 0]) rounded_stud(d, h);
        }
    }
}

union(){
    translate([0,0,plate_t/2]) cube([plate_len, plate_w, plate_t], center=true);
    translate([0,0,plate_t]) stud_row(stud_count, plate_len - stud_d, stud_d, stud_h);
}