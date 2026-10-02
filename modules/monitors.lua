------------------
---- MONITORS ----
------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Samsung Odyssey G40B: panel nativo 1920x1080 de hasta 240Hz.
-- El modo "2560x1440@144" que estaba aqui antes no existe en este monitor,
-- por eso Hyprland caia al default de 120Hz.
hl.monitor({
    output = "DP-1",
    mode = "1920x1080@239.76",
    position = "0x0",
    scale = 1,

    -- VRR apagado a proposito: en shooters competitivos anade latencia variable.
    vrr = 0,
})

-- Modo "gaming" de respaldo a 120Hz por si algo va mal con el de 240Hz.
--hyprctl keyword monitor DP-1,1920x1080@120,0x0,1