-- Load libraries
os.loadAPI("/rom/programs/facility/libraries/tls.lua"); -- Load Crypto library
os.loadAPI("/rom/programs/facility/libraries/fusion.lua"); -- Load Fusion Server communication library
os.loadAPI("/rom/programs/facility/libraries/auth.lua"); -- Load Fusion Auth communication library
os.loadAPI("/rom/programs/facility/libraries/invanalysis.lua"); -- Load InvAnalysis

os.loadAPI("/rom/programs/facility/libraries/facility_views.lua"); -- Load the Application view object library
os.loadAPI("/rom/programs/facility/libraries/facility_actions.lua");

local active = true;
local lastError = nil;

local monitor = peripheral.wrap("monitor_0");
local gpu = peripheral.wrap("GPU_0");
local magstripe = peripheral.wrap("mag card reader_0");
local diskdrive = peripheral.wrap("drive_0");
local printer = peripheral.wrap("printer_0");
local modem = peripheral.wrap("back");

local loadingView = newView("Loading", function(view, monitor)
monSizeW, monSizeH = monitor.getSize();
local text = "Please wait.";

monitor.setTextScale(0.5)
monitor.setCursorPos((monSizeW / 2) - string.len(text), monSizeH / 2);
monitor.write(text);
end);

local errorView = newView("Error", function(view, monitor);
monSizeW, monSizeH = monitor.getSize();
local text = "Oh shit, an error occurred!";
local description = lastError.description;
local source = "Source: " .. lastError.source;
local contact = "Please contact an administrator.";

monitor.setTextColor(colors.red);
monitor.setTextScale(1);
monitor.setCursorPos((monSizeW / 2) - string.len(text), monSizeH / 2);
monitor.write(text);

monitor.setCursorPos((monSizeW / 2) - string.len(description), (monSizeH / 2) + 2);
monitor.write(description);

monitor.setCursorPos((monSizeW / 2) - string.len(source), (monSizeH / 2) + 4);
monitor.write(source);

monitor.setCursorPos((monSizeW / 2) - string.len(contact), (monSizeH / 2) + 8);
monitor.write(contact);
end);

function plotFilledRect(x, y, nextx, nexty)
gpu.filledRectangle(x, y, (nextx-x)+1, (nexty-y)+1);
end

monitor.clear();
modem.closeAll();
term.clear();
term.write("Please wait, resetting system...\n");

if (!term.isColor() || !monitor.isColor())
  error("Fatal error: Terminal or monitor does not support colour! Ensure both are Advanced.");
end

switchToView(loadingView, monitor);

-- Set up GPU
gpuW, gpuH = gpu.getSize(0);

gpu.setColor(0, 0, 0); -- set color black
gpu.fill();

gpu.setColor(255, 255, 255); -- set color white

plotFilledRect(0, 0, 2, gpuH); -- left bar
plotFilledRect(gpuW - 2, 0, gpuW, gpuH); -- right bar
plotFilledRect(2, 0, gpuW, 2); -- top bar
plotFilledRect(2, gpuH - 2, gpuW - 2, gpuH); -- bottom bar

local gpuText = "Please wait, GPU initializing.";
gpu.drawText(gpuText, (gpuW / 2) - string.len(gpuText), gpuH / 2);

term.write("Initialized application. System ready.\nPlease see monitor for more information.");

-- Application main loop here.
while active == true do
  local callbacks = {};
  table.insert(callbacks, callViewHooks);
  table.insert(callbacks, function()
  local err = os.pullEvent("view_fatalError");
  -- A fatal error occured!
  lastError = err;
  active = false;
  end)
  -- Additional event handlers should be added here.

  parallel.waitForAny(unpack(callbacks));
end

if (lastError ~= nil) then
  switchToView(errorView, monitor);
end
