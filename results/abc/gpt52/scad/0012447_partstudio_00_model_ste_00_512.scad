$fn=64;

th = 0.02;
L = 0.2;
H = 0.1;

bow_od = 0.08;
bow_id = 0.04;
bow_center_x = L/2 - bow_od/2;

bit_len = 0.06;
bit_h = 0.06;

shank_len = L - bow_od/2 - bit_len;
shank_h = 0.03;

module bow_ring(thk){
    difference(){
        cylinder(h=thk, d=bow_od, center=true);
        cylinder(h=thk+0.01, d=bow_id, center=true);
    }
}

module shank(thk){
    translate([(-L/2 + shank_len/2), 0, 0])
        cube([shank_len, shank_h, thk], center=true);
}

module bit_base(thk){
    translate([(-L/2 + bit_len/2), 0, 0])
        cube([bit_len, bit_h, thk], center=true);
}

module bit_notches(thk){
    union(){
        translate([(-L/2 + 0.018), 0.018, 0])
            cube([0.018, 0.018, thk+0.02], center=true);
        translate([(-L/2 + 0.032), -0.02, 0])
            cube([0.02, 0.02, thk+0.02], center=true);
        translate([(-L/2 + 0.048), 0.0, 0])
            cube([0.016, 0.014, thk+0.02], center=true);
    }
}

module triangular_tooth(thk){
    linear_extrude(height=thk, center=true)
        polygon(points=[
            [-L/2 + 0.012, -0.01],
            [-L/2 + 0.012,  0.01],
            [-L/2 + 0.000,  0.00]
        ]);
}

module key_plate(){
    difference(){
        union(){
            translate([bow_center_x, 0, 0]) bow_ring(th);
            shank(th);
            bit_base(th);
            triangular_tooth(th);
        }
        bit_notches(th);
    }
}

key_plate();