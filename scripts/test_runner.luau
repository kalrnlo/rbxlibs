
-- test runner
-- script for running tests for ci

local process = require("@lune/process")
local fs = require("@lune/fs")
local ansi = require("ansi")

for _, lib in fs.readDir("libs") do
	local path = `libs/{lib}/test`
	local file_path = `{path}.luau`
	local real_path: string
	local contents: string

	if fs.isDir(path) then
		local init_path = `{path}/init.luau`

		if fs.isFile(init_path) then
			contents = fs.readFile(init_path)
			real_path = init_path
		else
			error(ansi.boldred(`LIBRARY {lib} HAS A TEST DIRECTORY WITH NO FILE CALLED "init.luau" IN IT`))
		end
	elseif fs.isFile(file_path) then
		contents = fs.readFile(file_path)
		real_path = file_path
	else
		continue
	end

	-- test not implemented and its just a placeholder as a reminder
	if #contents == 0 then
		continue
	end

	fs.writeFile(real_path, `{contents}\n\nassert(FINISH())\nprint()`)
	;(require)(`../{real_path}`)
	fs.writeFile(real_path, contents)
end

process.exit(0)