// Timing pulley: 16 teeth, 12.16mm pitch diameter
// Single connected solid with visible discrete timing-pulley-like teeth (trapezoidal)

$fn = 180;

// ---------------- Parameters ----------------
teeth = 16;
pitch_diameter = 12.16;
pitch_r = pitch_diameter/2;

// Pulley width (Z)
belt_width = 6;

// Tooth geometry (approx timing pulley profile; trapezoid in plan view)
tooth_height = 1.2;          // radial height from root to tip
tooth_tip_w = 0.7;           // tangential width at tooth tip
tooth_root_w = 1.6;          // tangential width at tooth root (wider than tip)

// Root radius chosen so pitch circle lies between root and tip
root_clearance = 0.6;        // pitch circle above root by this amount
root_r = pitch_r - root_clearance;
tip_r  = root_r + tooth_height;

// Hub/body (keep simple; no flanges, no set screw hole)
hub_diameter = 10;
hub_length   = belt_width;   // match belt width for a simple pulley body

bore_diameter = 5;

// Connectivity overlap
overlap = 0.25;

// ---------------- Helpers ----------------
module tooth_prism(h) {
    // Trapezoid tooth extruded along Z (h)
    // Local coordinates: X = radial, Y = tangential
    // Root face at x=0, tip face at x=tooth_height
    linear_extrude(height=h, center=true, convexity=10)
        polygon(points=[
            [0,            -tooth_root_w/2],
            [0,             tooth_root_w/2],
            [tooth_height,  tooth_tip_w/2],
            [tooth_height, -tooth_tip_w/2]
        ]);
}

module toothed_body() {
    union() {
        // Base cylinder up to root radius
        cylinder(h=belt_width, r=root_r, center=true);

        // Teeth: protrude outward, overlap into root cylinder for connectivity
        for (i = [0:teeth-1]) {
            rotate([0,0,i*360/teeth])
                translate([root_r - overlap, 0, 0])  // root face slightly inside cylinder
                    tooth_prism(belt_width);
        }
    }
}

module pulley() {
    difference() {
        union() {
            // Ensure one connected solid: hub overlaps toothed body
            cylinder(h=hub_length, d=hub_diameter, center=true);
            toothed_body();
        }

        // Bore through entire part
        cylinder(h=hub_length + 2, d=bore_diameter, center=true);
    }
}

pulley();