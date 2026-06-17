// PTFE sleeving / tubing (single connected solid)

// Parameters
sleeve_length   = 1000; //[500:2000:10]
inner_diameter  = 4;    //[2:8:0.1]
outer_diameter  = 6;    //[3:12:0.1]
wall_thickness  = 1;    //[0.5:2:0.1] // Informational
end_chamfer     = 0.5;  //[0:2:0.1]
connect_overlap = 1;    //[0.5:2:0.1]
rib_pitch       = 20;   //[5:50:1]
rib_width       = 2;    //[0.5:5:0.1]
rib_height      = 0.2;  //[0:0.6:0.05]
rib_count       = 40;   //[0:200:1]

// Quality
$fn = 96;

// Safety / derived
eps = 0.02;

// Ensure valid diameters and non-zero wall
od = max(outer_diameter, inner_diameter + 2*eps);
id = min(inner_diameter, od - 2*eps);
id = max(id, eps);

rib_h = max(rib_height, 0);
rib_w = max(rib_width, eps);
rib_p = max(rib_pitch, rib_w + eps);

ch = max(end_chamfer, 0);
ov = max(connect_overlap, eps);

// Base tube (hollow)
module tube_body() {
    difference() {
        cylinder(h=sleeve_length, r=od/2, center=true);
        // extend inner cut to guarantee through-hole
        cylinder(h=sleeve_length + 2*ov, r=id/2, center=true);
    }
}

// Chamfer cuts (remove material at ends)
module chamfer_cuts() {
    if (ch > 0) {
        // Use cones that extend beyond ends to ensure a clean chamfer cut
        ch_h = ch + ov;

        // Top chamfer cut
        translate([0, 0, sleeve_length/2 - ch_h/2])
            cylinder(h=ch_h, r1=od/2 + ov, r2=max(od/2 - ch, eps), center=true);

        // Bottom chamfer cut
        translate([0, 0, -sleeve_length/2 + ch_h/2])
            cylinder(h=ch_h, r1=max(od/2 - ch, eps), r2=od/2 + ov, center=true);
    }
}

// External ribs (kept connected by slight overlap into tube)
module ribs() {
    if (rib_h > 0 && rib_count > 0) {
        rib_r = od/2 + rib_h;

        // Ensure ribs overlap into the tube surface so union is one connected solid
        rib_z_overlap = min(ov, rib_w/2 - eps);
        rib_z_overlap = max(rib_z_overlap, eps);

        // Place ribs along length using pitch; clamp to stay within tube ends
        max_i = min(rib_count - 1, floor((sleeve_length - rib_w) / rib_p));
        for (i = [0:max_i]) {
            zpos = -sleeve_length/2 + rib_w/2 + i*rib_p;
            translate([0, 0, zpos])
                cylinder(h=rib_w + 2*rib_z_overlap, r=rib_r, center=true);
        }
    }
}

// Final model
module ptfe_sleeving() {
    difference() {
        union() {
            tube_body();
            ribs();
        }
        chamfer_cuts();
    }
}

color([0.85, 0.85, 0.8]) ptfe_sleeving();