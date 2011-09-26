#= require module/sellstome

{expandApiURL} = sellstome.common

@AD_CREATE_L =        'ad:create.local'
@AD_UPDATE_L =        'ad:update.local'
@AD_DELETE_L =        'ad:delete.local'
@AD_CREATE_R =        'ad:create.remote'
@AD_UPDATE_R =        'ad:update.remote'
@AD_DELETE_R =        'ad:delete.remote'
@AD_UPLOAD_L =        'ad:upload.local'
@AD_UPLOAD_DELETE_L = 'ad:upload:delete.local'
@TAB_SWITCH_L =       "tab:switch.local";
@SEARCH_SEARCH_L =    "search:search.local";
@MAP_SHOW_DETAILS_L = "map:showDetails.local";
@MAP_HIDE_DETAILS_L = "map:hideDetails.local";
@AD_UPLOAD_URL =      expandApiURL('/ads/upload')
@AD_API_URL =         expandApiURL('/ads')
@BAYEUX_URL =         expandApiURL('/bayeux')