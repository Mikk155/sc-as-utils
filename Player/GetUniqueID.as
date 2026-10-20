namespace Player
{
    /**
    *   @brief Gets a stable player identifier for Steam, bot, and LAN players.
    *   @param player Player whose identifier is requested. If null, an empty string is returned.
    *   Bots and LAN players receive a prefix plus their current player name.
    **/
    string GetUniqueID( CBasePlayer@ player )
    {
        if( player is null )
        {
            return String::EMPTY_STRING;
        }

        string authID = g_EngineFuncs.GetPlayerAuthId( player.edict() );

        if( authID == "BOT" )
        {
            snprintf( authID, "BOT_%1", string( player.pev.netname ) );
        }
        else if( authID == "STEAM_ID_LAN" )
        {
            snprintf( authID, "LAN_%1", string( player.pev.netname ) );
        }

        return authID;
    }
}
