// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 75; //[40:160:1]
length_mm = 250; //[125:500:1]
ht75_outer_diameter = 75; //[60:90:0.5]
ht75_wall_thickness = 2.7; //[1.5:5.4:0.1]
fitting_length = 35; //[20:70:1]
fitting_outer_diameter = 86; //[78:110:0.5]
fitting_wall_thickness = 3.2; //[2:6.4:0.1]
connection_overlap = 1; //[0.5:2:0.1]
bore_clearance = 0.2; //[0:0.6:0.05]

$fn = 128;

// HT Pipe Segment - ONE connected solid (outer union, inner void subtracted once)
module ht_pipe() {
    outer_r = ht75_outer_diameter/2;
    inner_r = outer_r - ht75_wall_thickness - bore_clearance;

    fit_outer_r = fitting_outer_diameter/2;
    fit_inner_r = fit_outer_r - fitting_wall_thickness - bore_clearance;

    // Ensure valid radii
    inner_r2 = max(0.01, inner_r);
    fit_inner_r2 = max(0.01, fit_inner_r);

    // Socket overlaps into pipe to guarantee connection
    fit_z0 = length_mm - fitting_length + connection_overlap;

    // Inner bores extend slightly beyond ends to avoid coplanar/blank artifacts
    eps = 0.05;

    color([0.85, 0.85, 0.8])
    difference() {
        // OUTER: union of pipe + socket (connected via overlap)
        union() {
            cylinder(h=length_mm, r=outer_r, center=false);
            translate([0, 0, fit_z0])
                cylinder(h=fitting_length, r=fit_outer_r, center=false);
        }

        // INNER: continuous bore through entire part
        union() {
            // Pipe bore
            translate([0, 0, -eps])
                cylinder(h=length_mm + 2*eps, r=inner_r2, center=false);

            // Socket bore
            translate([0, 0, fit_z0 - eps])
                cylinder(h=fitting_length + 2*eps, r=fit_inner_r2, center=false);
        }
    }
}

// Assembly
module assembly() {
    ht_pipe();
}

assembly();