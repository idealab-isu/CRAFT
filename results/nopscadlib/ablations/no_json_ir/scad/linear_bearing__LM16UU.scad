// Linear bearing (LM16UU-style approximation)
// Dimensions: 16.0mm bore, 28.0mm OD, 37.0mm length

bore_diameter   = 16.0;
outer_diameter  = 28.0;
bearing_length  = 37.0;

$fn = 180;

module linear_bearing() {
    r_out = outer_diameter/2;
    r_in  = bore_diameter/2;

    // Typical LMxxUU cosmetic features (kept within OD/length)
    end_relief_w   = 1.2;   // small end relief width
    end_relief_d   = 0.35;  // small end relief depth (radial)
    mid_groove_w   = 2.0;   // center groove width
    mid_groove_d   = 0.6;   // center groove depth (radial)

    // Ball track scallops (cosmetic) on the inner bore
    track_count    = 6;
    track_r        = 0.9;   // scallop radius
    track_depth    = 0.55;  // how far scallop center sits outside the bore radius
    track_z_margin = 2.0;   // keep away from ends

    eps = 0.02;

    difference() {
        // Outer sleeve (centered for easier feature placement)
        cylinder(h=bearing_length, r=r_out, center=true);

        // Through bore
        cylinder(h=bearing_length + 2*eps, r=r_in, center=true);

        // Center outer groove (subtractive)
        translate([0, 0, 0])
            difference() {
                cylinder(h=mid_groove_w, r=r_out + 1, center=true);          // ensure full cut
                cylinder(h=mid_groove_w + 2*eps, r=r_out - mid_groove_d, center=true);
            }

        // End relief grooves (subtractive), placed by formulas from length
        for (s = [-1, 1]) {
            translate([0, 0, s*(bearing_length/2 - end_relief_w/2)])
                difference() {
                    cylinder(h=end_relief_w, r=r_out + 1, center=true);
                    cylinder(h=end_relief_w + 2*eps, r=r_out - end_relief_d, center=true);
                }
        }

        // Inner ball-track scallops (cosmetic), kept inside the body
        track_len = max(0.1, bearing_length - 2*track_z_margin);
        for (i = [0:track_count-1]) {
            rotate([0, 0, i*360/track_count])
                translate([r_in + track_depth, 0, 0])
                    cylinder(h=track_len, r=track_r, center=true);
        }
    }
}

linear_bearing();