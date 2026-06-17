// HT 32 pipe 1500 mm

$fn = 128;

// Parameters
length_mm = 1500;            //[750:3000:10]
outer_diameter_mm = 32;      //[16:64:1]
wall_thickness_mm = 1.8;     //[0.9:3.6:0.1]
epsilon_mm = 0.2;            //[0.05:1:0.05]

// Derived
outer_r = outer_diameter_mm/2;
inner_r = max(outer_r - wall_thickness_mm, 0.01);

// Place pipe along X so standard Front/Back/Left/Right views show a long pipe (not a tiny dot)
module ht_pipe() {
    color([0.85, 0.85, 0.8])
    rotate([0, 90, 0])  // cylinder axis: Z -> X
    difference() {
        cylinder(h=length_mm, r=outer_r, center=true);
        cylinder(h=length_mm + 2*epsilon_mm, r=inner_r, center=true);
    }
}

ht_pipe();