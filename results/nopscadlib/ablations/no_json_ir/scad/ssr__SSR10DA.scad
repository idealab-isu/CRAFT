$fn = 64;

// Solid State Relay module overall size (mm)
L = 58.0;   // length (X)
W = 45.0;   // width  (Y)
H = 33.0;   // height (Z)

module ssr_module() {
    // Ensure a visible, non-degenerate, single connected solid
    // (use a tiny epsilon to avoid any zero-thickness edge cases in some renderers)
    eps = 0.01;

    cube([L, W, H] + [eps, eps, eps], center=true);
}

ssr_module();