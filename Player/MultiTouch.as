/**
*   MIT License
*
*   Copyright (c) 2026 Mikk155
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
    int __LastMultiTouchIndex__ = 0;

    void MultiTouchReset()
    {
        __LastMultiTouchIndex__ = 0;
    }

    /**
    * @brief Return true for all valid players that are intersecting with @p other
    *
    * @param other entity that is being touch.
    * @param player resulting player.
    *
    * If MultiTouch doesn't finish its iteration of all players and it's used again it will continue with the last player index:
    * @code
    * Entity::MultiTouchReset();
    * @endcode
    * Example:
    * @code
    * CBasePlayer@ player;
    *
    * while( Entity::MultiTouch( self, player ) )
    * {
    *   if( ( player.pev.button & IN_USE ) != 0 )
    *   {
    *       g_EntityFuncs.FireTargets( string( self.pev.target ), player, self, USE_TOGGLE );
    *       Entity::MultiTouchReset();
    *       break;
    *   }
    * }
    * @endcode
    */
    bool MultiTouch( CBaseEntity@ other, CBasePlayer@&out player )
    {
        if( other !is null )
        {
            while( __LastMultiTouchIndex__ < g_Engine.maxClients )
            {
                __LastMultiTouchIndex__++;
                auto entity = g_PlayerFuncs.FindPlayerByIndex(__LastMultiTouchIndex__);

                if( entity !is null && entity.IsConnected() && other.Intersects( entity ) )
                {
                    @player = entity;
                    return true;
                }
            }

            __LastMultiTouchIndex__ = 0;
        }

        return false;
    }
}
