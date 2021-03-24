scanner = nil
fluxStorage = nil
version = "0.1"
fluxLev = nil
fluxMax = nil
fluxPercent = nil

function scannerPresent()
  scanner = peripheral.wrap("top")
  return not(scanner == nil)
end

function storagePresent()
  local blockMeta = scanner.getBlockMeta(0, 1, 0)
  return (blockMeta.name == "fluxnetworks:fluxstorage")
end

function storageConditions()
  fluxStorage = scanner.getBlockMeta(0, 1, 0)

  fluxLev = textutils.serialize(fluxStorage.rf.stored)
  fluxMax = textutils.serialize(fluxStorage.rf.capacity)
  fluxPercent = ((fluxLev / fluxMax) * 100)
end

--@function:: trim
--@purpose::  trim the numbers after the decimal point of a number
--@params::
--  num;      The number to truncate
--  figures;  how many figures we want after the decimalpoint
--@returns::
--  the truncated number
function trim(num, figures)
  return math.floor(num * 10^figures) /10^figures
end

function toString()
  result = string.format("Flux Storage Version: %s\n",version)
  result = result ..              "Flux Storage Status:\n"
  result = result .. string.format("        Capacity: %s RF\n", fluxMax)
  result = result .. string.format("        Stored: %s RF\n", fluxLev)
  result = result ..             "\nAdditonal Info:\n"
  return result
end --toString()

--@function:: output
--@purpose::  print the data
function output()
  term.clear()
  term.setCursorPos(1,1)
  print(toString())
end

function toggleEvent()
  local scannerAttached = scannerPresent()
  local isStorage = storagePresent()
  if scannerPresent and isStorage then
    storageConditions()
    output()
    os.startTimer(0.5)
    while true do
      local args = { os.pullEvent() }
      if args[1] == "key" then
        if args[2] == 184 then
          print("Break break break!")
          break
        end
      elseif args[1] == "timer" then
        storageConditions()
        output()
        os.startTimer(0.5)
      end
    end
  else
    if not(scannerPresent) then print("No Scanner Module present") end
    if not(isStorage) then print("No Flux Storage Present") end
  end
end

toggleEvent()
