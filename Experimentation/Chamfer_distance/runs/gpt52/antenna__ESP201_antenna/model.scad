$fn = 64;

total_len = 108.5;
base_d = 9.5;
tip_d = 7.9;

fixed_len = 20.6;
pivot_from_base = 20.6;

panel_gap = 6.45;

hinge_clearance = 0.3;        // clearance between hinge parts
hinge_wall = 1.6;             // thickness around hinge bore
hinge_bore_d = 3.2;           // pivot pin hole diameter
knuckle_len = 6.0;            // length of each knuckle along axis
knuckle_end_margin = 2.0;     // spacing from hinge ends to knuckles

fold_angle = 35;              // folded angle for demonstration

function lerp(a,b,t) = a + (b-a)*t;

module whip_shaft(len, d0, d1) {
    cylinder(h=len, d1=d0, d2=d1);
}

module hinge_female(r_out, bore_d, gap, len) {
    // Outer body
    difference() {
        translate([0,0,0])
            cylinder(h=len, r=r_out);
        // Split slot for male blade (panel gap)
        translate([-r_out, -gap/2, -1])
            cube([2*r_out, gap, len+2], center=false);
        // Pivot bore (across Y axis)
        translate([0,0,len/2])
            rotate([90,0,0])
                cylinder(h=2*r_out+2, d=bore_d, center=true);
    }
    // Add two knuckles (top and bottom) leaving middle open
    kn_z1 = knuckle_end_margin;
    kn_z2 = len - knuckle_end_margin - knuckle_len;
    for (zpos=[kn_z1, kn_z2]) {
        difference() {
            translate([0,0,zpos])
                cylinder(h=knuckle_len, r=r_out);
            translate([-r_out, -gap/2, zpos-1])
                cube([2*r_out, gap, knuckle_len+2], center=false);
            translate([0,0,zpos+knuckle_len/2])
                rotate([90,0,0])
                    cylinder(h=2*r_out+2, d=bore_d, center=true);
        }
    }
}

module hinge_male(blade_w, blade_t, bore_d, len) {
    // A blade that fits into the female gap, with single central knuckle
    union() {
        // Blade body
        translate([-blade_t/2, -blade_w/2, 0])
            cube([blade_t, blade_w, len], center=false);

        // Central knuckle around bore
        difference() {
            translate([0,0,(len-knuckle_len)/2])
                cylinder(h=knuckle_len, d=blade_w);
            translate([0,0,len/2])
                rotate([90,0,0])
                    cylinder(h=blade_w+2, d=bore_d, center=true);
            // remove anything outside blade thickness to keep it blade-like
            translate([blade_t/2, -blade_w, -1])
                cube([blade_w, 2*blade_w, len+2], center=false);
            translate([-blade_w - blade_t/2, -blade_w, -1])
                cube([blade_w, 2*blade_w, len+2], center=false);
        }
    }
}

module folding_whip_antenna() {
    remaining_len = total_len - fixed_len;
    r0 = base_d/2;
    r1 = tip_d/2;

    // Compute diameter at pivot for smooth taper
    d_pivot = lerp(base_d, tip_d, pivot_from_base/total_len);
    r_pivot = d_pivot/2;

    // Hinge geometry derived from sizes and gap
    female_r_out = max(r_pivot + hinge_wall, (panel_gap/2) + hinge_wall);
    male_blade_w = panel_gap - hinge_clearance;
    male_blade_t = max(3.2, r_pivot*0.8); // thickness of blade
    hinge_len = 16.0;

    // Fixed straight section (from base to pivot)
    union() {
        // Fixed tapered shaft up to pivot
        whip_shaft(fixed_len, base_d, d_pivot);

        // Female hinge attached at pivot end
        translate([0,0,fixed_len])
            hinge_female(female_r_out, hinge_bore_d, panel_gap, hinge_len);

        // Male hinge + folding whip section (folded for visualization)
        translate([0,0,fixed_len + hinge_len/2])
            rotate([0, fold_angle, 0])
                translate([0,0,-hinge_len/2])  // pivot about bore center
                    union() {
                        // Male hinge blade
                        hinge_male(male_blade_w, male_blade_t, hinge_bore_d, hinge_len);

                        // Continuation shaft from hinge outward
                        translate([0,0,hinge_len])
                            whip_shaft(remaining_len, d_pivot, tip_d);
                    }
    }
}

translate([0,0,-total_len/2 + 8]) folding_whip_antenna();