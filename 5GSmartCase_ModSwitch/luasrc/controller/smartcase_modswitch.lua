local sys = require "luci.sys"
local http = require "luci.http"
local translate = require "luci.i18n".translate

module("luci.controller.smartcase_modswitch", package.seeall)

local modes = {
	["1"] = "CDC-NCM",
	["2"] = "CDC-ECM",
	["3"] = "RNDIS"
}

local function trim(value)
	return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function shell_quote(value)
	return "'" .. tostring(value or ""):gsub("'", "'\\''") .. "'"
end

local function adb_devices()
	local devices = {}
	local total = 0
	local output = sys.exec("adb devices 2>/dev/null")

	for line in output:gmatch("[^\r\n]+") do
		local serial, state = line:match("^([^%s]+)%s+([^%s]+)")
		if serial and serial ~= "List" then
			total = total + 1
			if state == "device" and serial:match("^[%w%._:%-]+$") then
				devices[#devices + 1] = serial
			end
		end
	end

	return devices, total
end

local function adb_cmd(serial, remote_cmd)
	return string.format("adb -s %s shell %s", serial, shell_quote(remote_cmd))
end

local function read_current_mode(serial)
	local value = trim(sys.exec(adb_cmd(serial, "cat /mnt/data/mode.cfg") .. " 2>/dev/null"))

	return {
		value = value,
		name = modes[value] or translate("Unknown")
	}
end

local function adb_status()
	local devices, total = adb_devices()
	local status = {
		connected = (#devices == 1 and total == 1),
		count = #devices,
		total = total
	}

	if status.connected then
		local current_mode

		status.device = devices[1]
		status.message = translate("5G Smart Case ADB connected")

		current_mode = read_current_mode(status.device)
		status.current_mode_value = current_mode.value
		status.current_mode = current_mode.name
	else
		status.current_mode_value = ""
		status.current_mode = "-"
		status.message = translate("5G Smart Case ADB not connected")
	end

	return status
end

function index()
	entry({"admin", "network", "smartcase_modswitch"}, template("smartcase_modswitch/index"), translate("5G Smart Case Network Mode Switch"), 90).dependent = true
	entry({"admin", "network", "smartcase_modswitch", "status"}, call("action_status")).leaf = true
	entry({"admin", "network", "smartcase_modswitch", "switch"}, call("action_switch")).leaf = true
	entry({"admin", "network", "smartcase_modswitch", "shell_exec"}, call("action_shell_exec")).leaf = true
end

function action_status()
	http.prepare_content("application/json")
	http.write_json(adb_status())
end

function action_switch()
	local mode = http.formvalue("mode")
	local result = adb_status()

	result.success = false

	if not modes[mode] then
		result.message = translate("Invalid network mode")
	elseif not result.connected then
		result.message = translate("5G Smart Case ADB not connected")
	else
		local serial = result.device
		local write_cmd = adb_cmd(serial, "echo " .. mode .. " > /mnt/data/mode.cfg")
		local cat_cmd = adb_cmd(serial, "cat /mnt/data/mode.cfg")

		if sys.call(adb_cmd(serial, "sync") .. " >/dev/null 2>&1") ~= 0 then
			result.message = translate("ADB sync failed")
		elseif sys.call(write_cmd .. " >/dev/null 2>&1") ~= 0 then
			result.message = translate("Failed to write permanent mode configuration")
		elseif sys.call(adb_cmd(serial, "sync") .. " >/dev/null 2>&1") ~= 0 then
			result.message = translate("Post-write sync failed")
		else
			local readback = trim(sys.exec(cat_cmd .. " 2>/dev/null"))
			if readback ~= mode then
				result.message = translate("Configuration verification failed, current value:") .. " " .. (readback ~= "" and readback or translate("empty"))
			else
				sys.call(adb_cmd(serial, "/sbin/reboot") .. " >/dev/null 2>&1 &")
				result.success = true
				result.mode = modes[mode]
				result.message = translate("Switched to") .. " " .. modes[mode] .. ", " .. translate("5G Smart Case is rebooting")
			end
		end
	end

	http.prepare_content("application/json")
	http.write_json(result)
end

function action_shell_exec()
	local command = http.formvalue("command") or ""
	local result = adb_status()

	result.success = false
	result.output = ""

	if not result.connected then
		result.message = translate("5G Smart Case ADB not connected")
	elseif trim(command) == "" then
		result.message = translate("Command is empty")
	else
		result.output = sys.exec(adb_cmd(result.device, command) .. " 2>&1")
		result.success = true
		result.message = translate("Command executed")
	end

	http.prepare_content("application/json")
	http.write_json(result)
end
