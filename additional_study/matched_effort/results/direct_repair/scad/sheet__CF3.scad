$fn = 96;

// Carbon fiber sheet parameters
sheet_len = 120;     // mm
sheet_wid = 80;      // mm
sheet_thk = 2.0;     // mm
corner_r  = 3.0;     // mm

// Visual appearance (approximate carbon fiber look)
cf_base = [0.08, 0.09, 0.10];
cf_dark = [0.03, 0.03, 0.035];
cf_mid  = [0.12, 0.13, 0.14];

module rounded_rect_2d(l, w, r){
    r2 = min(r, min(l, w)/2);
    hull() {
        translate([ r2,  r2]) circle(r=r2);
        translate([l-r2,  r2]) circle(r=r2);
        translate([ r2, w-r2]) circle(r=r2);
        translate([l-r2, w-r2]) circle(r=r2);
    }
}

module carbon_fiber_texture_2d(l, w, cell=6, stripe=1.2){
    // Base
    color(cf_base) square([l,w], center=false);

    // Diagonal weave approximation using clipped stripes
    intersection() {
        square([l,w], center=false);
        union() {
            // +45 deg stripes
            rotate(45)
            for (x = [-2*(l+w) : cell : 2*(l+w)]) {
                translate([x, -2*(l+w)])
                    color(cf_dark) square([stripe, 4*(l+w)], center=false);
            }
            // -45 deg stripes
            rotate(-45)
            for (x = [-2*(l+w) : cell : 2*(l+w)]) {
                translate([x, -2*(l+w)])
                    color(cf_mid) square([stripe, 4*(l+w)], center=false);
            }
        }
    }
}

module carbon_fiber_sheet(l, w, t, r){
    // Geometry
    difference() {
        linear_extrude(height=t)
            rounded_rect_2d(l, w, r);
    }

    // Top surface visual overlay (thin)
    translate([0,0,t-0.05])
    linear_extrude(height=0.05)
    intersection() {
        rounded_rect_2d(l, w, r);
        carbon_fiber_texture_2d(l, w, cell=6, stripe=1.2);
    }

    // Slight edge darkening
    color([0.02,0.02,0.025])
    difference() {
        linear_extrude(height=t)
            offset(delta=0.0) rounded_rect_2d(l, w, r);
        translate([0,0,0.02])
        linear_extrude(height=t-0.04)
            offset(delta=-0.6) rounded_rect_2d(l, w, r);
    }
}

// Center on origin
translate([-sheet_len/2, -sheet_wid/2, 0])
carbon_fiber_sheet(sheet_len, sheet_wid, sheet_thk, corner_r);