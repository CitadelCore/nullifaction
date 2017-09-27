-- Load libraries
os.loadAPI("/rom/programs/facility/libraries/tls.lua"); -- Load Crypto library
os.loadAPI("/rom/programs/facility/libraries/fusion.lua"); -- Load Fusion Server communication library
os.loadAPI("/rom/programs/facility/libraries/auth.lua"); -- Load Fusion Auth communication library
os.loadAPI("/rom/programs/facility/libraries/invanalysis.lua"); -- Load InvAnalysis

function plotFilledRect(x, y, nextx, nexty)
gpu.filledRectangle(x, y, (nextx-x)+1, (nexty-y)+1)
end

monitor = peripheral.wrap("monitor_0");
gpu = peripheral.wrap("GPU_0");
magcard = peripheral.wrap("mag card reader_0");
diskdrive = peripheral.wrap("drive_0");
printer = peripheral.wrap("printer_0");
modem = peripheral.wrap("back");

monitor.clear();
modem.closeAll();
term.clear();
term.write("Please wait, resetting system...");
os.sleep(1);
term.clear();

monSizeW, monSizeH = monitor.getSize()
monitor.clear()
monitor.setBackgroundColor(32768)
monitor.setBackgroundColor(32768)
monitor.setCursorPos(2, 1)
monitor.write("Nullification")
monitor.setCursorPos((monSizeW / 2) - 12, 1)
monitor.write("Base Command and Control")
monitor.setTextScale(0.5)
monitor.setCursorPos(2, 24)
monitor.write("Please wait while the system initializes.")
monitor.setCursorPos(monSizeW - 5, 1)
monitor.setBackgroundColor(colors.blue)
monitor.write(string.rep(" ",6))
monitor.setTextColor(colors.white)
monitor.setCursorPos(monSizeW - 4, 1)
monitor.write("Help")
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.white)

-- Set up GPU
gpu.setColor(0, 0, 0) -- set color black
gpu.fill()
gpu.setColor(255, 255, 255) -- set color white
plotFilledRect(0, 0, 2, 128) -- left bar
plotFilledRect(221, 0, 223, 127) -- right bar
plotFilledRect(2, 0, 220, 2) -- top bar
plotFilledRect(2, 124, 220, 127) -- top bar
