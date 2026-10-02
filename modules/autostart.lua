-------------------
---- AUTOSTART ----
-------------------

-- Fondo de pantalla.
-- `swww` ya no existe en ningun repositorio (fue absorbido por aww),
-- asi que las transiciones las da `awww-daemon`.
-- restore.sh levanta el daemon si hace falta y recupera el ultimo fondo.
hl.on("hyprland.start", function ()
    hl.exec_cmd("$HOME/.config/hypr/scripts/coverflow/restore.sh")
end)

-- Ver https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
-- hl.on("hyprland.start", function ()
--   hl.exec_cmd(terminal)
--   hl.exec_cmd("nm-applet")
-- end)