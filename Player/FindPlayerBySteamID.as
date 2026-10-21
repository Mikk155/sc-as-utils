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
                return player;
        }
        return null;
    }
}
