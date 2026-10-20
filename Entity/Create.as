namespace Entity
{
    /**
     * Creates an entity using the classname and key-values in a dictionary.
     *
     * @param keyvalues Entity key-values. Must include a "classname" entry; an optional
     *                  "origin" entry is also applied as the entity's world position.
     * @param owner Edict assigned as the entity's owner, or null if it has no owner.
     * @param spawnNow Whether CreateEntity should spawn the entity immediately.
     *                 DispatchSpawn is called before returning when true.
     */
    CBaseEntity@ Create( dictionary&in keyvalues, edict_t@ owner = null, bool spawnNow = true )
    {
        if( !keyvalues.exists( "classname" ) )
            return null;

        CBaseEntity@ entity = g_EntityFuncs.CreateEntity( string( keyvalues[ "classname" ] ), keyvalues, spawnNow );

        if( entity is null )
            return null;

        @entity.pev.owner = owner;

        if( keyvalues.exists( "origin" ) )
        {
            Vector VecPos;
            g_Utility.StringToVector( VecPos, string( keyvalues[ "origin" ] ) );
            g_EntityFuncs.SetOrigin( entity, VecPos );
        }

        if( spawnNow )
        {
            g_EntityFuncs.DispatchSpawn( entity.edict() );
        }

        return entity;
    }

    /**
     * Creates an entity using the classname and key-values in a dictionary, with a
     * CBaseEntity owner whose edict is assigned to the new entity.
     *
     * @param keyvalues Entity key-values. Must include a "classname" entry; an optional
     *                  "origin" entry is also applied as the entity's world position.
     * @param owner Entity assigned as the new entity's owner, or null if it has no owner.
     * @param spawnNow Whether CreateEntity should spawn the entity immediately.
     *                 DispatchSpawn is called before returning when true.
     */
    CBaseEntity@ Create( dictionary&in keyvalues, CBaseEntity@ owner, bool spawnNow = true )
    {
        return Create( keyvalues, ( owner !is null ? owner.edict() : null ) , spawnNow);
    }

    /**
     * Creates an entity after setting the supplied classname in its key-values.
     *
     * @param classname Entity classname to write into keyvalues before creation.
     * @param keyvalues Additional entity key-values. An optional "origin" entry is
     *                  applied as the entity's world position.
     * @param owner Edict assigned as the entity's owner, or null if it has no owner.
     * @param spawnNow Whether CreateEntity should spawn the entity immediately.
     *                 DispatchSpawn is called before returning when true.
     */
    CBaseEntity@ Create( const string&in classname, dictionary&in keyvalues, edict_t@ owner = null, bool spawnNow = true )
    {
        keyvalues[ "classname" ] = classname;
        return Create( keyvalues, owner, spawnNow);
    }

    /**
     * Creates an entity with the supplied classname and a CBaseEntity owner.
     *
     * @param classname Entity classname to write into keyvalues before creation.
     * @param keyvalues Additional entity key-values. An optional "origin" entry is
     *                  applied as the entity's world position.
     * @param owner Entity assigned as the new entity's owner, or null if it has no owner.
     * @param spawnNow Whether CreateEntity should spawn the entity immediately.
     *                 DispatchSpawn is called before returning when true.
     */
    CBaseEntity@ Create( const string&in classname, dictionary&in keyvalues, CBaseEntity@ owner, bool spawnNow = true )
    {
        return Create( classname, keyvalues, ( owner !is null ? owner.edict() : null ), spawnNow );
    }
}
