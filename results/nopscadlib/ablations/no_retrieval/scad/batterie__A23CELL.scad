$fn = 128;

// Battery cell target dimensions (overall envelope)
cell_height   = 28.5;   // mm (overall height)
cell_diameter = 10.3;   // mm (overall diameter)

// Small overlap to guarantee manifold unions/differences
overlap = 0.2; // mm

r_cell = cell_diameter/2;

// Simple, single-solid cell: no holes/indents/buttons/bands.
// This ensures orthographic views are consistent and dimensions are unambiguous.
module battery_cell() {
    cylinder(h=cell_height, r=r_cell, center=true);
}

battery_cell();