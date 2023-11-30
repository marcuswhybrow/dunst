{ ... }: {
  global = {
    follow = "keyboard"; # display notifications where I'm typing

    origin = "top-right";
    offset = "60x40";
    frame_width = 1;
    frame_color = "#eee";
    font = "Noto Sans 12";
    markup = "full";
    transparency = 0; # transparency doesn't work on wayland

    padding = 20;
    horizontal_padding = 20;

    line_height = 0;

    separator_height = 1;
    separator_color = "#000000";

    progress_bar_corner_radius = 2;
    progress_bar_height = 5;
    progress_bar_frame_width = 0; 

    # distance between notifications
    gap_size = 10;

    corner_radius = 3;

    background = "#fafafa";
    foreground = "#666";
    highlight = "#336";
  };

  urgency_low = {
    timeout = 10;
  };

  urgency_normal = {
    timeout = 10;
  };

  urgency_critical = {
    background = "#fdd";
    foreground = "#d33";
    highlight = "#ff0000";
    frame_color = "#fbb";
    timeout = 0;
  };

  volume = {
    appname = "changeVolume";
    urgency = "low";
    timeout = 2000;
    format = ''   Volume'';
  };

  brightness = {
    appname = "changeBrightness";
    urgency = "low";
    timeout = 2000;
    format = ''  Brightness'';
  };
}
