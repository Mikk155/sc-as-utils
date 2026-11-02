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
    /**
    * @brief Return whatever @p player is facing towards @p target.
    *
    * @details CBasePlayer::IsFacing is failing for some reason so i just made my own check.
    */
    bool IsFacing( CBasePlayer@ player, CBaseEntity@ target, float dot = 0.5f )
    {
        Vector vecSrc = player.pev.origin + player.pev.view_ofs;

        TraceResult tr;
        g_Utility.TraceLine( vecSrc, target.pev.origin, ignore_monsters, ignore_glass, player.edict(), tr );

        if( tr.flFraction < 1.0 )
            return false;

        Math.MakeVectors( player.pev.v_angle );
        Vector vecToTarget = ( target.pev.origin - vecSrc ).Normalize();
        return ( DotProduct( g_Engine.v_forward, vecToTarget ) >= dot );
    }
}
