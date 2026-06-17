// Render-safe stepped sleeve/connector (rotationally symmetric)
$fn = 48;

// Target bounding box (approx): 12.0 x 27.2 x 27.2 mm (elongated along Z)
L = 12.0;                 // overall length (Z)
D_max = 27.2;             // maximum OD (ribs)
D_mid = 24.8;             // main body OD
D_neck = 22.6;            // neck OD (between collars and mid)
D_end_collar = 26.2;      // end collar OD

L_end_collar = 1.2;       // each end collar axial length
L_mid_section = 6.6;      // central section axial length
overlap = 0.10;           // small overlap to guarantee connectivity

// Two prominent recessed bands near midsection (grooves)
band_w = 1.25;
band_gap = 1.10;
band_depth_rad = 1.10;

// Small end relief grooves
end_relief_w = 0.65;
end_relief_depth_rad = 0.65;

// Raised ribs (circumferential rings) near ends of mid section
rib_count = 6;
rib_w = 0.55;
rib_h_rad = 0.55;

// Edge chamfer (simple conical cut)
chamfer_ax = 0.55;

// Derived lengths
L_neck_total = max(0, L - L_mid_section - 2*L_end_collar);
L_neck_each  = L_neck_total/2;

// Axial landmarks (centered at Z=0)
z_left_end        = -L/2;
z_right_end       =  L/2;

z_left_collar_c   = z_left_end  + L_end_collar/2;
z_right_collar_c  = z_right_end - L_end_collar/2;

z_left_neck_c     = z_left_end  + L_end_collar + L_neck_each/2;
z_right_neck_c    = z_right_end - L_end_collar - L_neck_each/2;

module outer_profile_union() {
    union() {
        // Mid section (main body)
        cylinder(r=D_mid/2, h=L_mid_section + 2*overlap, center=true);

        // Necks
        if (L_neck_each > 0) {
            translate([0,0,z_left_neck_c])
                cylinder(r=D_neck/2, h=L_neck_each + 2*overlap, center=true);
            translate([0,0,z_right_neck_c])
                cylinder(r=D_neck/2, h=L_neck_each + 2*overlap, center=true);
        }

        // End collars
        translate([0,0,z_left_collar_c])
            cylinder(r=D_end_collar/2, h=L_end_collar + 2*overlap, center=true);

        translate([0,0,z_right_collar_c])
            cylinder(r=D_end_collar/2, h=L_end_collar + 2*overlap, center=true);
    }
}

module raised_ribs() {
    if (rib_count <= 0) { /* no ribs */ }
    else {
        margin = 0.25;
        z_min = -L_mid_section/2 + margin + rib_w/2;
        z_max =  L_mid_section/2 - margin - rib_w/2;

        // Groove centers
        z_g1 = -(band_gap/2 + band_w/2);
        z_g2 =  (band_gap/2 + band_w/2);

        // Exclusion half-span around each groove
        excl = band_w/2 + 0.20;

        for (i = [0:rib_count-1]) {
            t = (rib_count==1) ? 0.5 : i/(rib_count-1);
            zi = z_min + t*(z_max - z_min);

            ok = (abs(zi - z_g1) > (excl + rib_w/2)) && (abs(zi - z_g2) > (excl + rib_w/2));
            if (ok)
                translate([0,0,zi])
                    cylinder(r=min(D_max/2, D_mid/2 + rib_h_rad),
                             h=rib_w + 2*overlap, center=true);
        }
    }
}

module recessed_mid_bands_cuts() {
    z1 = -(band_gap/2 + band_w/2);
    z2 =  (band_gap/2 + band_w/2);

    // Cut rings: subtract only the outer annulus (avoid coplanar/degenerate booleans)
    for (zv = [z1, z2]) {
        translate([0,0,zv])
            difference() {
                cylinder(r=D_mid/2 + 0.02, h=band_w + 2*overlap, center=true);
                cylinder(r=max(0.01, D_mid/2 - band_depth_rad),
                         h=band_w + 2*overlap + 0.04, center=true);
            }
    }
}

module end_relief_grooves_cuts() {
    zL = z_left_end + L_end_collar + end_relief_w/2;
    zR = z_right_end - L_end_collar - end_relief_w/2;

    for (zv = [zL, zR]) {
        translate([0,0,zv])
            difference() {
                cylinder(r=D_neck/2 + 0.02, h=end_relief_w + 2*overlap, center=true);
                cylinder(r=max(0.01, D_neck/2 - end_relief_depth_rad),
                         h=end_relief_w + 2*overlap + 0.04, center=true);
            }
    }
}

module end_chamfer_cuts() {
    // Slightly oversize radii to ensure clean subtraction
    translate([0,0,z_left_end + chamfer_ax/2])
        cylinder(r1=0.01, r2=D_end_collar/2 + 0.05, h=chamfer_ax + 2*overlap, center=true);

    translate([0,0,z_right_end - chamfer_ax/2])
        cylinder(r1=D_end_collar/2 + 0.05, r2=0.01, h=chamfer_ax + 2*overlap, center=true);
}

module solid_connector() {
    difference() {
        union() {
            outer_profile_union();
            raised_ribs();
        }
        recessed_mid_bands_cuts();
        end_relief_grooves_cuts();
        end_chamfer_cuts();
    }
}

solid_connector();