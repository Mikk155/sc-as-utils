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

namespace Entity
{
    /**
     * Pre-caches an entity described by key-values without spawning it into the world.
     *
     * @param keyvalues Entity key-values. Must contain the entity's "classname".
     *                  The temporary entity is marked for removal after Precache.
     */
    bool Precache( dictionary@ keyvalues )
    {
        CBaseEntity@ entity = g_EntityFuncs.CreateEntity( string( keyvalues[ "classname" ] ), keyvalues, false );

        if( entity is null )
            return false;

        entity.Precache();
        entity.pev.flags |= FL_KILLME;

        return true;
    }

    /**
     * Pre-caches an entity after setting its classname in the supplied key-values.
     *
     * @param classname Classname of the entity whose resources should be pre-cached.
     * @param keyvalues Additional entity key-values passed to entity creation.
     */
    bool Precache( string classname, dictionary@ keyvalues )
    {
        keyvalues[ "classname" ] = classname;
        return Precache( keyvalues );
    }
}
