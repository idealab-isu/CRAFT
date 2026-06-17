$fn=96;

// IEC-style lugless blade terminal (simplified)
// Units: mm

// Parameters
blade_len = 14.0;
blade_w   = 6.3;
blade_t   = 0.8;

base_len  = 10.0;
base_w    = 8.0;
base_t    = 1.6;

neck_len  = 3.0;
neck_w    = 6.3;
neck_t    = 1.2;

tip_chamfer = 1.2;

module chamfered_blade(len, w, t, chamfer=1.0){
    // Blade with a simple chamfered leading edge
    difference(){
        translate([0, -w/2, -t/2]) cube([len, w, t], center=false);
        // remove two wedges at the tip to create a chamfer
        translate([len-chamfer, -w/2-0.01, -t/2-0.01])
            rotate([0,45,0])
                cube([chamfer*2, w+0.02, t+0.02], center=false);
    }
}

module iec_lugless(){
    union(){
        // Base pad (where it would be crimped/attached; no lug/hole)
        translate([0, -base_w/2, -base_t/2])
            cube([base_len, base_w, base_t], center=false);

        // Neck transition
        translate([base_len, -neck_w/2, -neck_t/2])
            cube([neck_len, neck_w, neck_t], center=false);

        // Blade
        translate([base_len+neck_len, 0, 0])
            chamfered_blade(blade_len, blade_w, blade_t, tip_chamfer);

        // Small fillets via hull between base and neck (visual smoothing)
        hull(){
            translate([base_len-0.01, 0, 0])
                cube([0.02, neck_w, neck_t], center=true);
            translate([base_len-0.01, 0, 0])
                cube([0.02, base_w, base_t], center=true);
        }

        // Small fillets via hull between neck and blade
        hull(){
            translate([base_len+neck_len+0.01, 0, 0])
                cube([0.02, blade_w, blade_t], center=true);
            translate([base_len+neck_len+0.01, 0, 0])
                cube([0.02, neck_w, neck_t], center=true);
        }
    }
}

iec_lugless();