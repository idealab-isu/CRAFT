// HT 32 pipe 1000 mm (single connected solid)

// Parameters
length_mm = 1000; //[500:2000:10]
ht32_outer_diameter = 32; //[16:64:1]
ht32_wall_thickness = 1.8; //[0.9:3.6:0.1]
end_fitting_length = 35; //[18:70:1]
end_fitting_radial_add = 2.5; //[1.25:5:0.1]
overlap_mm = 1; //[0.5:2:0.1]
center = 0; //[0:1:1]

$fn = 128;

// HT Pipe - complete geometry
module ht_pipe() {
    outer_r = ht32_outer_diameter/2;
    inner_r = outer_r - ht32_wall_thickness;
    fitting_outer_r = outer_r + end_fitting_radial_add;

    // Robustness epsilons (avoid coincident faces)
    eps = 0.02;

    // Place either at Z=0..L or centered about origin
    z0 = (center == 1) ? -length_mm/2 : 0;

    color([0.85, 0.85, 0.8])  // PVC color
    translate([0, 0, z0])
    union() {
        // Main pipe (hollow)
        difference() {
            cylinder(h=length_mm, r=outer_r, center=false);
            translate([0, 0, -eps])
                cylinder(h=length_mm + 2*eps, r=inner_r, center=false);
        }

        // End fitting (socket) at the "top" end, overlapping into main pipe
        // Connected by overlap_mm (no floating)
        translate([0, 0, length_mm - end_fitting_length - overlap_mm])
        difference() {
            cylinder(h=end_fitting_length + overlap_mm, r=fitting_outer_r, center=false);
            translate([0, 0, -eps])
                cylinder(h=end_fitting_length + overlap_mm + 2*eps, r=inner_r, center=false);
        }
    }
}

// Assembly
module assembly() {
    ht_pipe();
}

assembly();