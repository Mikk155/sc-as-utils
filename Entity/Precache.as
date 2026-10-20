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
