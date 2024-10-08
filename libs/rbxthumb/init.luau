
-- rbxthumb
-- module for easily creating roblox thumbnail urls, based on nevermores rbxthumbutil
-- although with types 

type PlayerThumbnailFormatter<sizes> = (player: Player, size: sizes?, circular: boolean?) -> string
type ThumbnailFormatter<sizes> = (id: number, size: sizes?, circular: boolean?) -> string

export type ThumbnailType = "Asset" | "Avatar" | "AvatarHeadShot" | "BadgeIcon"  | 
	"BundleThumbnail" | "GameIcon" | "GamePass" | "GroupIcon" | "Outfit" | "FontFamily" | 
	"AvatarBust"

export type ThumbnailSize = "1200×80" | "720x720" | "420x420" |"352x352" | "150x150" | 
	"100x100" | "60x60" | "50x50" | "48x48" | "180x180"

type AvatarHeadshotThumbnailSize = "48×48" | "60×60" | "100×100" | "150×150" | "180×180" |
	"352×352" | "420×420"

type AvatarBustThumbnailSize = "100x100" | "150x15" | "75×75" | "100×100" | "150×150" | "180×180" | 
	"352×352" | "420×420"

type FullAvatarThumbnailSize = "50×50" | "60×60" | "75×75" | "100×100" | "150×150" | "180×180" | 
	"352×352" | "420×420"


-- making an enum var rq so no errors occur in lune
local Enum = Enum or table.freeze({
	AvatarItemType = table.freeze({
		Asset = 1,
	})
})

local BASE_URL = "rbxthumb://type=%s&id=%d&w=%d&h=%d"
local CIRCULAR_URL = `{BASE_URL}&filters=circular`
local ASSET_ENUM = Enum.AvatarItemType.Asset
local BUNDLE_STR = "BundleThumbnail"
local DEFUALT_SIZE_NUM = 150
local ASSET_STR = "Asset"
local X = "x"

local function RAW_FORMAT(id: number, type: ThumbnailType, width: number, height: number, circular: boolean?): string
	return string.format(
		if circular then CIRCULAR_URL else BASE_URL,
		type,
		id,
		width,
		height
	)
end

local function SPLIT_SIZE(size: ThumbnailSize?, default_width: number, default_height: number): (number, number)
	if size then
		local splitted = string.split(size, X)
		return tonumber(splitted[1]) or default_width, tonumber(splitted[2]) or default_height
	else
		return default_width, default_height
	end
end

local function FORMAT_RBXTHUMB_URL(id: number, type: ThumbnailType, size: ThumbnailSize?, circular: boolean?): string
	local width, height = SPLIT_SIZE(size, DEFUALT_SIZE_NUM, DEFUALT_SIZE_NUM)
	return RAW_FORMAT(id, type, width, height, circular)
end

local function CREATE_PLAYER_FORMATTER<sizes>(type: ThumbnailType, default_width: number?, default_height: number?): PlayerThumbnailFormatter<sizes>
	local defualt_height = default_height or DEFUALT_SIZE_NUM
	local defualt_width = default_width or DEFUALT_SIZE_NUM

	return function(player: Player, size: sizes?, circular: boolean?): string
		local width, height = SPLIT_SIZE(size :: any, defualt_width, defualt_height)
		return RAW_FORMAT(player.UserId, type, width, height, circular)
	end
end

local function CREATE_FORMATTER<sizes>(type: ThumbnailType, default_width: number?, default_height: number?): ThumbnailFormatter<sizes>
	local defualt_height = default_height or DEFUALT_SIZE_NUM
	local defualt_width = default_width or DEFUALT_SIZE_NUM

	return function(id: number, size: sizes?, circular: boolean?): string
		local width, height = SPLIT_SIZE(size :: any, defualt_width, defualt_height)
		return RAW_FORMAT(id, type, width, height, circular)
	end
end

local function avatar_item_type_to_thumbnail_type(avatar_item_type: Enum.AvatarItemType): "Asset" | "BundleThumbnail"
	return if avatar_item_type == ASSET_ENUM then ASSET_STR :: any else BUNDLE_STR :: any
end

local function avatar_item_to_thumbnail(
	avatar_item_type: Enum.AvatarItemType,
	id: number, 
	size: ("150x150" | "420x420")?,
	circular: boolean?
): string
	return if avatar_item_type == ASSET_ENUM then
		FORMAT_RBXTHUMB_URL(id, ASSET_STR :: any, size, circular)
	else 
		FORMAT_RBXTHUMB_URL(id, BUNDLE_STR :: any, size, circular)
end

local exports = table.freeze {
	avatar = table.freeze {
		headshot = CREATE_FORMATTER("AvatarHeadShot") :: ThumbnailFormatter<AvatarHeadshotThumbnailSize>,
		bust = CREATE_FORMATTER("AvatarBust") :: ThumbnailFormatter<AvatarBustThumbnailSize>,
		full = CREATE_FORMATTER("Avatar") :: ThumbnailFormatter<FullAvatarThumbnailSize>,
		item = avatar_item_to_thumbnail,
	},
	player = table.freeze {
		headshot = CREATE_PLAYER_FORMATTER("AvatarHeadShot") :: PlayerThumbnailFormatter<AvatarHeadshotThumbnailSize>,
		bust = CREATE_PLAYER_FORMATTER("AvatarBust") :: PlayerThumbnailFormatter<AvatarBustThumbnailSize>,
		full = CREATE_PLAYER_FORMATTER("Avatar") :: PlayerThumbnailFormatter<FullAvatarThumbnailSize>,
	},
	bundle = CREATE_FORMATTER("BundleThumbnail") :: ThumbnailFormatter<"150x150" | "420x420">,
	fontfamily = CREATE_FORMATTER("FontFamily", 1200, 80) :: ThumbnailFormatter<"1200×80">,
	group = CREATE_FORMATTER("GroupIcon") :: ThumbnailFormatter<"150x150" | "420x420">,
	outfit = CREATE_FORMATTER("Outfit") :: ThumbnailFormatter<"150x150" | "420x420">,
	asset = CREATE_FORMATTER("Asset") :: ThumbnailFormatter<"150x150" | "420x420">,
	experience = CREATE_FORMATTER("GameIcon"):: ThumbnailFormatter<"150x150">,
	gamepass = CREATE_FORMATTER("GamePass") :: ThumbnailFormatter<"150x150">,
	badge = CREATE_FORMATTER("BadgeIcon") :: ThumbnailFormatter<"150x150">,
	urlformats = table.freeze {
		circular = CIRCULAR_URL,
		base = BASE_URL,
	},

	avatar_item_type_to_thumbnail_type = avatar_item_type_to_thumbnail_type,
	format = FORMAT_RBXTHUMB_URL,
}

return exports