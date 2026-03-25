// Dimension-calibrated (target: 0.03 x 0.03 x 0.02 mm)
scale([0.001000, 0.001000, 0.001053])
{
$fn = 128;

// Units: meters in parameters below; convert to mm for modeling
mm = 1000;

// -------------------- Parameters (as given) --------------------
disk_d = 0.03;
disk_t = 0.012;

rim_radial_thk = 0.003;
rim_extra_t = 0.004;

hub_d = 0.012;
hub_h = 0.004;

hex_flat_to_flat = 0.006;
hex_clearance = 0.0002;

post_d = 0.006;
post_h = 0.004;

cutout_count = 4;
cutout_w = 0.004;
cutout_h = 0.004;
cutout_depth = 0.012;
cutout_radial_pos = 0.012;
cutout_corner_r = 0.001;

overlap = 0.001; // meters

// -------------------- Derived (mm) --------------------
disk_r      = (disk_d*mm)/2;
disk_h      =  disk_t*mm;

rim_thk_r   =  rim_radial_thk*mm;
rim_h       = (disk_t + rim_extra_t)*mm;

hub_r       = (hub_d*mm)/2;
hub_hh      =  hub_h*mm;

post_r      = (post_d*mm)/2;
post_hh     =  post_h*mm;

cut_w       =  cutout_w*mm;     // tangential width
cut_len     =  cutout_h*mm;     // radial length
cut_hh      =  cutout_depth*mm; // cutter height
cut_rpos    =  cutout_radial_pos*mm;
cut_cr      =  cutout_corner_r*mm;

eps         =  overlap*mm;      // mm overlap for robust unions/differences

// Hex sizing: for a regular hex, flat-to-flat = R * sqrt(3) where R is circumradius
hex_ftf     = (hex_flat_to_flat + hex_clearance)*mm;
hex_R       = hex_ftf / sqrt(3);

// -------------------- Helpers --------------------
module rounded_rect2d(w, h, r){
    r2 = min(r, min(w,h)/2);
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(w/2 - r2), sy*(h/2 - r2)]) circle(r=r2);
    }
}

module curved_perimeter_cutout(){
    // Curved rectangular slot near perimeter:
    // rounded rectangle intersected with an annulus band to curve inner/outer edges.
    intersection(){
        translate([cut_rpos, 0, 0])
            linear_extrude(height = rim_h + 2*eps, center=true)
                rounded_rect2d(cut_len, cut_w, cut_cr);

        linear_extrude(height = rim_h + 2*eps, center=true)
            difference(){
                circle(r = disk_r - rim_thk_r/2);
                circle(r = disk_r - rim_thk_r - cut_len - rim_thk_r/2);
            }
    }
}

module four_cutouts(){
    for(i=[0:cutout_count-1])
        rotate([0,0,i*360/cutout_count]) curved_perimeter_cutout();
}

module base_disk(){
    cylinder(r=disk_r, h=disk_h, center=true);
}

module outer_rim(){
    // Taller outer band to make rim thickness visible in side view.
    difference(){
        cylinder(r=disk_r, h=rim_h, center=true);
        cylinder(r=disk_r - rim_thk_r, h=rim_h + 2*eps, center=true);
    }
}

module hub(){
    // Raised hub on +Z face; increase step visibility by lifting it above the rim top.
    // Ensure solid connection by overlapping into the rim/disk by eps.
    // Place hub so its bottom is slightly below the rim top.
    z0 = (rim_h/2) - eps;                 // hub bottom (slightly into rim)
    zc = z0 + hub_hh/2;                   // hub center
    translate([0,0,zc])
        cylinder(r=hub_r, h=hub_hh, center=true);
}

module post(){
    // Short shaft on -Z face; make it clearly protrude from one face.
    // Ensure solid connection by overlapping into the rim/disk by eps.
    // Place post so its top is slightly above the rim bottom.
    z1 = -(rim_h/2) + eps;                // post top (slightly into rim)
    zc = z1 - post_hh/2;                  // post center
    translate([0,0,zc])
        cylinder(r=post_r, h=post_hh, center=true);
}

module hex_bore(){
    // Through hex bore across entire part (rim + hub + post), with margin.
    total_h = rim_h + hub_hh + post_hh + 8*eps;
    cylinder(r=hex_R, h=total_h, center=true, $fn=6);
}

// -------------------- Model --------------------
difference(){
    union(){
        base_disk();
        outer_rim();
        hub();
        post();
    }

    // Cutouts and bore
    four_cutouts();
    hex_bore();
}
}
