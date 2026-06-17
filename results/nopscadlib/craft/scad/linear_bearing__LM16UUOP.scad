// Linear bearing (LM16UU-like) — 16mm bore, 28mm OD, 37mm length
// Output is a single connected solid (a hollow cylinder). No external protrusions.

bore_diameter_mm  = 16.0;
outer_diameter_mm = 28.0;
length_mm         = 37.0;

eps_mm = 0.05;   // small tolerance for clean boolean ops
$fn = 128;

module linear_bearing_16_28_37() {
    bore_r  = bore_diameter_mm/2;
    outer_r = outer_diameter_mm/2;

    difference() {
        // Outer cylinder
        cylinder(r=outer_r, h=length_mm, center=true);

        // Through bore
        cylinder(r=bore_r, h=length_mm + 2*eps_mm, center=true);
    }
}

linear_bearing_16_28_37();