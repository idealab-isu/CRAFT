$fn = 180;

// Timing pulley (approximate GT2-like tooth form) with 20 teeth and 12.22mm pitch diameter.
// Note: Tooth profile is an approximation suitable for visualization/printing.

teeth = 20;
pitch_d = 12.22;          // pitch diameter (mm)
pitch_r = pitch_d/2;

pulley_width = 10;        // axial width (mm)
hub_d = 16;               // outer diameter at tooth tips region (will be overridden by teeth)
bore_d = 5;               // center bore (mm)

flange = true;
flange_th = 1.2;
flange_od_extra = 3.0;    // flange OD beyond tooth OD

// Tooth geometry (approx)
tooth_height = 0.75;      // radial height above pitch circle (mm)
tooth_root = 0.35;        // radial depth below pitch circle (mm)
tooth_top_w = 0.55;       // tangential width at tooth tip (mm)
tooth_base_w = 1.15;      // tangential width at tooth base (mm)

// Derived radii
r_root = pitch_r - tooth_root;
r_tip  = pitch_r + tooth_height;

// Ensure body OD at least covers tooth tips
body_r = r_tip;

// Tooth angular pitch
tooth_pitch_ang = 360 / teeth;

// Convert tangential widths to angular widths at respective radii
function ang_from_tangential(w, r) = (w / (2*PI*r)) * 360;

tooth_ang_tip  = ang_from_tangential(tooth_top_w,  r_tip);
tooth_ang_base = ang_from_tangential(tooth_base_w, r_root);

// Main
difference() {
    union() {
        // Core cylinder up to root radius
        cylinder(h=pulley_width, r=r_root, center=true);

        // Teeth
        for (i = [0:teeth-1]) {
            rotate([0,0,i*tooth_pitch_ang])
                tooth();
        }

        // Optional flanges
        if (flange) {
            flange_r = r_tip + flange_od_extra/2;
            translate([0,0, (pulley_width/2 + flange_th/2)])
                cylinder(h=flange_th, r=flange_r, center=true);
            translate([0,0, -(pulley_width/2 + flange_th/2)])
                cylinder(h=flange_th, r=flange_r, center=true);
        }
    }

    // Bore
    cylinder(h=pulley_width + 2*flange_th + 2, d=bore_d, center=true);
}

module tooth() {
    // A trapezoidal prism in polar placement, approximating a belt tooth.
    // Built as a 2D polygon in XY then extruded along Z.
    linear_extrude(height=pulley_width, center=true, convexity=10)
        polygon(points=[
            polar(r_root, -tooth_ang_base/2),
            polar(r_root,  tooth_ang_base/2),
            polar(r_tip,   tooth_ang_tip/2),
            polar(r_tip,  -tooth_ang_tip/2)
        ]);
}

function polar(r, ang_deg) = [r*cos(ang_deg), r*sin(ang_deg)];