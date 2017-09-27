os.loadAPI("/rom/programs/facility/libraries/facility_actions.lua");

currentView = nil;

-- This method is intended to be called by the application's main loop, in a parallel arrangement,
-- if the application requires more than one callback methods to be excecuted.
-- This spawns parallel instances for each pullEvent for monitor touch events,
-- and handles monitor events in general.
function callViewHooks()
  for k, view in pairs(views) do
  if view == currentView then
    local buttonFunctions = {};
    for k, button in pairs(view.buttons) do
      local funct = function(x1, x2, y1, y2)
        -- Check whether the button is within the bounds defined
        -- by the "button" object.

        event, side, xPos, yPos = os.pullEvent("monitor_touch");
        if (xPos >= button.x1 && xPos <= button.x2 && yPos >= button.y1 && yPos <= button.y2) then
          button.onclick(view);
        end
      end

      table.insert(buttonFunctions, funct);
    end

    parallel.waitForAny(unpack(buttonFunctions));
  end
end

-- This method switches the current view
-- to the view specified. This basically blanks out the current view,
-- draws some hardcoded controls such as authentication and help buttons, and the title,
-- and then calls the render() delegate on the "view" object to actually render the view.
function switchToView(view, monitor)
  currentView = view;

  monSizeW, monSizeH = monitor.getSize();
  monitor.clear();
  monitor.setBackgroundColor(colors.black);
  monitor.setTextColor(colors.white);
  monitor.setTextScale(1);

  monitor.setCursorPos(2, 1);
  monitor.write("Nullification");

  monitor.setCursorPos(0, 1);

  monitor.setCursorPos(monSizeW - string.len(view.title), 1);
  monitor.write(view.title);

  -- Add hardcoded buttons here
  view.drawButton("Help", facility.buttonCallbacks.showHelp);

  -- Render buttons
  for k, button in pairs(view.buttons) do
    monitor.setCursorPos(button.x1, button.y1);
    monitor.setBackgroundColor(button.bgcolour);
    monitor.write(string.rep(" ", button.x2 - button.x1));
    monitor.setTextColor(colors.white);
    monitor.setCursorPos(button.x1 + 1, button.y1);
    monitor.write(button.text);
  end

  monitor.setCursorPos(0, 0);
  monitor.setBackgroundColor(colors.black);

  -- Call the render hook
  view.render(view, monitor);

  -- Call the onLoad hook, if exists
  if (view.onLoad ~= nil) then
    view.onLoad(view, monitor);
  end
end

-- Helper method for creating a new "view" object.
function newView(title, renderFunc)
  local view = {};
  view.title = title;
  view.render = renderFunc;
  view.buttons = {};
  view.drawButton = function(self, text, onclick, bgcolour, x, y)
    local button = newButton(text, onclick, bgcolour, x, y);
    table.insert(view.buttons, button);
  end
  view.onLoad = nil;
  view.tick = nil;

  return view;
end

-- Creates a new button. Should only be used within
-- the context of the view object, except in special cases.
-- This does not render the button, that is done in the switchToView method.
local function newButton(text, onclick, bgcolour, x, y)
  local button = {};
  button.text = text;
  button.onclick = onclick;
  button.bgcolour = bgcolour;

  -- add a padding of 1 for the button background. (horizontal only)
  button.x1 = x - 1;
  button.x2 = string.len(text) + 1;
  button.y1 = y;
  button.y2 = y;
end

local function newError(description, source)
local err = {};
err.description = description;
err.source = source;
err.throw = function(self)
os.queueEvent("view_fatalError", err);
end

return err;

end
