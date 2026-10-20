/**
 * Restores a player's score information after a temporary chat-color change.
 *
 * @param hplayer Handle to the player whose original score information should be resent.
 */
void __ResetChatColor__( EHandle hplayer )
{
    if( hplayer.IsValid() )
    {
        auto player = cast<CBasePlayer@>( hplayer.GetEntity() );

        if( player !is null && player.IsConnected() )
        {
            player.SendScoreInfo();
        }
    }
}

/**
 * Sends a colored chat message from a player.
 */
namespace ChatColor
{
    /**
     * Sets of supported colors.
     */
    enum Color
    {
        /**
         * Equals to CLASS_PLAYER (2) and it's the default chat color
         */
        LightBlue = CLASS_PLAYER,
        /**
         * Equals to CLASS_TEAM1 (16)
         */

        Blue = CLASS_TEAM1,
        /**
         * Equals to CLASS_TEAM2 (17)
         */
        Red = CLASS_TEAM2,
        /**
         * Equals to CLASS_TEAM3 (18)
         */
        Yellow = CLASS_TEAM3,
        /**
         * Equals to CLASS_TEAM4 (19)
         */
        Green = CLASS_TEAM4
    };

    /**
     * Temporarily applies a classification-based color to a player's chat messages.
     * The player's original classification is restored immediately; the score
     * information is resent shortly afterward to restore the normal scoreboard state.
     *
     * @param player Player whose outgoing chat should use the specified color.
     *               If null, no action is taken.
     * @param color Chat color to apply. Its value must be one of the Color enum entries.
     */
    void SetColor( CBasePlayer@ player, const Color&in color )
    {
        if( player is null )
            return;

        int classify = player.Classify();
        player.SetClassification( int( color ) );
        player.SendScoreInfo();
        player.SetClassification( classify );
        g_Scheduler.SetTimeout( "__ResetChatColor__", 0.1f, EHandle( player ) );
    }

    /**
     * Sends a colored chat message from one player to a single recipient.
     *
     * @param player Player shown as the message sender and whose chat color is changed.
     *               If null, no message is sent.
     * @param color Color applied to the sender's chat name/message.
     * @param message Text to send. A newline is not added automatically.
     * @param target Recipient of the message. If null, the message is sent back to
     *               player, so it is only visible to the sender.
     * @param insertPlayername If true, prefixes message with the sender's current
     *                         player name and ": ". Defaults to false.
     */
    void Say( CBasePlayer@ player,
        const Color&in color,
        const string&in message,
        CBasePlayer@ target = null,
        bool insertPlayername = false
    )
    {
        if( player is null )
            return;

        SetColor( player, color );

        if( target is null )
            @target = player;

        string buffer = message;

        if( insertPlayername )
            buffer = string( player.pev.netname ) + ": " + message;

        NetworkMessage m( MSG_ONE, NetworkMessages::SayText, target.edict() );
            m.WriteByte( player.entindex() );
            m.WriteByte( 2 );
            m.WriteString( buffer );
        m.End();
    }

    /**
     * Sends a colored chat message to everyone or to a selected group of players.
     *
     * @param player Player shown as the message sender and whose chat color is changed.
     *               If null, no message is sent.
     * @param color Color applied to the sender's chat name/message.
     * @param message Text to send. A newline is not added automatically.
     * @param targets Optional recipient list. If null, the message is broadcast to
     *                 all players; otherwise, it is sent only to the listed players.
     *                 An empty list sends the message to nobody.
     * @param insertPlayername If true, prefixes message with the sender's current
     *                         player name and ": ". Defaults to false.
     */
    void SayAll( CBasePlayer@ player,
        const Color&in color,
        const string&in message,
        array<CBasePlayer@>@ targets = null,
        bool insertPlayername = false
    )
    {
        if( player is null )
            return;

        SetColor( player, color );

        string buffer = message;

        if( insertPlayername )
            buffer = string( player.pev.netname ) + ": " + message;

        if( targets is null )
        {
            NetworkMessage m( MSG_ALL, NetworkMessages::SayText );
                m.WriteByte( player.entindex() );
                m.WriteByte( 2 );
                m.WriteString( buffer );
            m.End();
        }
        else
        {
            uint length = targets.length();

            for( uint ui = 0; ui < length; ui++ )
            {
                Say( player, color, buffer, targets[ui] );
            }
        }
    }
}
