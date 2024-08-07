--!optimize 2

-- pagesutil
-- utility for dealing with roblox page instancs easily

export type PageInfo = {
	item_index: number,
	page_len: number,
	page: number,
}

local advance_to_next_page_err_format = "[PAGES] an error occured while trying to advance to the next page\n\tadvance-next-page-err: %s"

local function iter(pages: Pages, f: (info: PageInfo, item: { [any]: any }) -> ("continue" | "break")?)
	local advance_to_next_page = pages.AdvanceToNextPageAsync
	local page = pages:GetCurrentPage()
	local page_info = {
		page_len = #page,
		item_index = 0,
		page = 1,
	}

	for item_index, item in page do
		page_info.item_index += 1
		local result = f(page_info, item)

		if result == "break" then
			return
		end
	end

	if not pages.IsFinished then
		repeat
			-- ive had issues with MemoryStoreHashMapPages erroring occasionally with this,
			-- because it didnt correctly set IsFinished to true when the hashmap had litterally 0 entries in it
			-- so its like litterally impossible for there to be another page
			local success, err = pcall(advance_to_next_page, pages)
			
			if success then
				local page = pages:GetCurrentPage()
				page_info.page_len = #page
				page_info.item_index = 0
				page_info.page += 1
	
				for item_index, item in page do
					page_info.item_index += 1
					local result = f(page_info, item)
		
					if result == "break" then
						return
					end
				end
			else
				warn(string.format(advance_to_next_page_err_format, err))
				return
			end
		until pages.IsFinished
	end
end

local function toarray(pages: Pages): { { [any]: any } }
	local advance_to_next_page = pages.AdvanceToNextPageAsync
	local contents = pages:GetCurrentPage()

	if not pages.IsFinished then
		repeat
			local success, err = pcall(advance_to_next_page, pages)

			if success then
				local current_page = pages:GetCurrentPage()
				table.move(current_page, 1, #current_page, #contents + 1, contents)
			else
				warn(string.format(advance_to_next_page_err_format, err))
				break
			end
		until pages.IsFinished
	end
	return contents
end

return table.freeze {
	toarray = toarray,
	iter = iter,
}
