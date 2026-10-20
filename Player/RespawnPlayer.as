namespace Player
{
    /**
    *   @brief Respawns a player and reports whether they are alive afterward.
    *   @param player Player to revive and respawn. The player's weapon loadout is retained.
    **/
    bool RespawnPlayer( CBasePlayer@ player )
    {
        player.Revive();
        g_PlayerFuncs.RespawnPlayer( player );
        return player.IsAlive();
    }
}
