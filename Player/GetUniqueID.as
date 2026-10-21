/**
*   MIT License
*
*   Copyright (c) 2025 Mikk155
*
*   Permission is hereby granted, free of charge, to any person obtaining a copy
*   of this software and associated documentation files (the "Software"), to deal
*   in the Software without restriction, including without limitation the rights
*   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*   copies of the Software, and to permit persons to whom the Software is
*   furnished to do so, subject to the following conditions:
*
*   The above copyright notice and this permission notice shall be included in all
*   copies or substantial portions of the Software.
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*   SOFTWARE.
**/

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
