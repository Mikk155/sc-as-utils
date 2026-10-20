#include "GetUniqueID"

namespace Player
{
    /**
     * Finds a connected player by the identifier returned from GetUniqueID.
     *
     * @param authID Steam authentication ID to match. For bots and LAN players, this
     *               must be the corresponding synthetic ID produced by GetUniqueID.
     */
    CBasePlayer@ FindPlayerBySteamID( const string&in authID )
    {
        CBasePlayer@ player = null;

        for( int i = 1; i <= g_Engine.maxClients; i++ )
        {
            if( ( @player = g_PlayerFuncs.FindPlayerByIndex( i ) ) !is null
            && player.IsConnected() && authID == GetUniqueID( player ) )
                break;
        }
        return player;
    }
}
