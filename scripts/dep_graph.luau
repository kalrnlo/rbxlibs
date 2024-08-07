
-- dep graph
-- module for generating a dependency graph for all libraries

local find_library_in_string = require("find_library_in_string")
local fs = require("@lune/fs")

local REQUIRE_PATTERN = "^local%s+%w+%s*=%s*require%s*%(%-?%-?[\"'](.+)[\"']%)$"
local GRAPH = {} :: { [string]: { string } }
local LINE_PATTERN = "[^\r\n]+"
local LIBS = fs.readDir("libs")

local function find_deps(lib: string, dir: string, dependencies_tbl: { string })
	for _, entry in fs.readDir(dir) do
		local entry_path = `{dir}/{entry}`
		
		-- does the file have a .luau extention
		if string.match(entry, "%.luau$") then
			local contents = fs.readFile(entry_path)

			for line in string.gmatch(contents, LINE_PATTERN) do
				local require_path = string.match(line, REQUIRE_PATTERN)

				if require_path then
					local deplib = find_library_in_string(require_path)
					
					if deplib and not table.find(dependencies_tbl, deplib) then
						table.insert(dependencies_tbl, deplib)
					end
				end
			end
		elseif fs.isDir(entry_path) then
			find_deps(lib, entry_path, dependencies_tbl)
		end
	end
end

for _, lib in LIBS do
	GRAPH[lib] = {}
end

for lib, dependencies_tbl in GRAPH do
	find_deps(lib, `libs/{lib}`, dependencies_tbl)
end

for _, dependencies_tbl in GRAPH do
	table.freeze(dependencies_tbl)
end

print(GRAPH)
return table.freeze(GRAPH)