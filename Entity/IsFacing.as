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

namespace Entity
{
    /**
    * @brief Return whatever @p entity is facing towards @p target.
    */
    bool IsFacing( CBaseEntity@ entity, CBaseEntity@ target, float dot = 0.5f )
    {
        Vector vecSrc = entity.pev.origin;
        Vector vecEnd = target.pev.origin;

        if( entity.IsPlayer() )
        {
            vecSrc = entity.pev.origin + entity.pev.view_ofs;
        }
        else if( entity.IsMonster() )
        {
            vecEnd = entity.EyePosition();
        }

        if( target.IsPlayer() )
        {
            vecEnd = target.pev.origin + target.pev.view_ofs;
        }
        else if( target.IsMonster() )
        {
            vecEnd = target.EyePosition();
        }
        else if( target.IsBSPModel() )
        {
            vecEnd = target.Center();
        }

        TraceResult tr;
        g_Utility.TraceLine( vecSrc, vecEnd, ignore_monsters, ignore_glass, entity.edict(), tr );

        if( tr.flFraction < 1.0 )
            return false;

        Math.MakeVectors( ( entity.IsPlayer() ? entity.pev.v_angle : entity.pev.angles ) );

        Vector vecToTarget = ( vecEnd - vecSrc ).Normalize();

        return ( DotProduct( g_Engine.v_forward, vecToTarget ) >= dot );
    }
}
