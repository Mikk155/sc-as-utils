namespace Player
{
    /**
    *   @brief Utility methods related to player's colormap variable.
    **/
    namespace Colormap
    {
        /**
        *   @brief Gets the player's bottom colormap component normalized to the range [0, 1].
        *   @param player Player whose bottom colormap component is read.
        **/
        float Bottom( CBasePlayer@ player )
        {
            return float( float( uint8( ( player.pev.colormap & 0xFF00 ) >> 8 ) ) / 255.0f );
        }

        /**
        *   @brief Gets the player's top colormap component normalized to the range [0, 1].
        *   @param player Player whose top colormap component is read. If null.
        **/
        float Top( CBasePlayer@ player )
        {
            return float( float( uint8( player.pev.colormap & 0x00FF ) ) / 255.0f );
        }
    }
}
