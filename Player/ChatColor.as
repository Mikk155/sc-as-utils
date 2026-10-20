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

namespace ChatColor
{
    enum Color
    {
        LightBlue = CLASS_PLAYER,
        Blue = CLASS_TEAM1,
        Red = CLASS_TEAM2,
        Yellow = CLASS_TEAM3,
        Green = CLASS_TEAM4
    };

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

    // Say to a specific player. if target is null it will be the same player input
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

    // Say to all, if targets is not null it will say only to these players.
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
