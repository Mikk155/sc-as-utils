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

/**
 * @brief Safe wrapper around an entity handle and its AngelScript interfaces.
 *
 * The wrapper stores an EHandle as its source of validity and lazily resolves
 * the requested entity interface. keeping a valid member property after a first retrieve of value to not cast constantly on every method retrieve call.
 */
class Entity
{
    EHandle m_EHandle;

    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CBaseEntity@ m_CBaseEntity;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected edict_t@ m_edict;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected entvars_t@ m_entvars;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CBaseMonster@ m_CBaseMonster;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CBasePlayer@ m_CBasePlayer;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CBaseDelay@ m_CBaseDelay;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CBaseAnimating@ m_CBaseAnimating;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CBaseToggle@ m_CBaseToggle;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CBasePlayerItem@ m_CBasePlayerItem;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CBasePlayerWeapon@ m_CBasePlayerWeapon;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CBasePlayerAmmo@ m_CBasePlayerAmmo;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CItemInventory@ m_ItemInventory;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CItem@ m_Item;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CGrenade@ m_Grenade;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CCineMonster@ m_CBaseCineMonster;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CSprite@ m_Sprite;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CPathTrack@ m_PathTrack;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CBeam@ m_Beam;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CLaser@ m_Laser;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CBaseTank@ m_CBaseTank;
#if DUMBSNIPER
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CPathCondition@ m_CBasePathCondition;
#endif
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CBaseButton@ m_CBaseButton;
    // DO NOT CALL USE IF @p m_EHandle IS NOT VALID!
    protected CBaseDoor@ m_CBaseDoor;
    protected CGib@ m_Gib;
    protected ScriptClassInterface@ m_ScriptClass;

    /**
     * @brief Clean up all handles for reuse.
     */
    void Clear()
    {
        this.m_EHandle = EHandle();
        @this.m_CBaseEntity = null;
        @this.m_edict = null;
        @this.m_entvars = null;
        @this.m_CBaseMonster = null;
        @this.m_CBasePlayer = null;
        @this.m_CBaseDelay = null;
        @this.m_CBaseAnimating = null;
        @this.m_CBaseToggle = null;
        @this.m_CBasePlayerItem = null;
        @this.m_CBasePlayerWeapon = null;
        @this.m_CBasePlayerAmmo = null;
        @this.m_ItemInventory = null;
        @this.m_Item = null;
        @this.m_Grenade = null;
        @this.m_CBaseCineMonster = null;
        @this.m_Sprite = null;
        @this.m_PathTrack = null;
        @this.m_Beam = null;
        @this.m_Laser = null;
        @this.m_CBaseTank = null;
#if DUMBSNIPER
        @this.m_CBasePathCondition = null;
#endif
        @this.m_CBaseButton = null;
        @this.m_CBaseDoor = null;
        @this.m_Gib = null;
        @this.m_ScriptClass = null;
    }

    /**
     * @brief Assign an entity handle to this wrapper.
     * @param handle Entity handle to store.
     * @return This wrapper.
     */
    Entity@ SetEntity( EHandle handle )
    {
        this.Clear();
        this.m_EHandle = handle;
        return this;
    }

    /**
     * @brief Assign an entity interface to this wrapper.
     * @param handle Entity interface used to create the internal handle.
     * @return This wrapper.
     */
    Entity@ SetEntity( CBaseEntity@ handle )
    {
        if( handle !is null )
        {
            this.SetEntity( EHandle( handle ) );
        }
        return this;
    }

    /**
     * @brief Assign another wrapper's entity to this wrapper.
     * @param handle Wrapper containing the entity handle to copy.
     * @return This wrapper.
     */
    Entity@ SetEntity( Entity@ handle )
    {
        this.Clear();

        if( handle !is null )
        {
            this.SetEntity( handle.toHandle );
        }
        return this;
    }

    Entity@ opHndlAssign( Entity@ handle )
    {
        if( handle !is null )
        {
            this.SetEntity( handle.toHandle );
        }
        return this;
    }

    Entity@ opHndlAssign( CBaseEntity@ handle )
    {
        this.SetEntity( handle );
        return this;
    }

    Entity@ opAssign( CBaseEntity@ handle )
    {
        this.SetEntity( handle );
        return this;
    }

    Entity@ opAssign( Entity&in handle )
    {
        EHandle copy = handle.m_EHandle;
        this.Clear();
        this.m_EHandle = copy;
        return this;
    }

    Entity@ opAssign( EHandle&in handle )
    {
        this.SetEntity( handle );
        return this;
    }

    /**
     * @brief Construct a wrapper by copying another wrapper.
     * @param handle Wrapper whose handle is copied.
     */
    Entity( Entity&in handle )
    {
        this.SetEntity( handle );
    }

    /**
     * @brief Construct a wrapper from an entity interface.
     * @param handle Entity interface used to create the internal handle.
     */
    Entity( CBaseEntity@ handle )
    {
        this.SetEntity( handle );
    }

    /**
     * @brief Construct a wrapper from an edict interface.
     * @param handle Entity interface used to create the internal handle.
     */
    Entity( edict_t@ handle )
    {
        this.SetEntity( g_EntityFuncs.Instance( handle ) );
    }


    /**
     * @brief Construct a wrapper from an entity index.
     * @param handle Entity index used to create the internal handle.
     */
    Entity( int handle )
    {
        this.SetEntity( g_EntityFuncs.Instance( handle ) );
    }

    /**
     * @brief Construct a wrapper from an entity handle.
     * @param handle Entity handle to store.
     */
    Entity( EHandle handle )
    {
        this.SetEntity( handle );
    }

    private bool m_HackEngineCopyMethod;

    /**
     * @brief Construct an empty wrapper.
     */
    Entity()
    {
        this.m_HackEngineCopyMethod = true;
    }

    bool opEquals( Entity@&in other )
    {
        return( other !is null && other.toEntity !is null && this.toEntity !is null && other.toEntity is this.toEntity );
    }

    /**
     * @brief Remove the wrapped entity immediately or mark it for removal.
     * UpdateOnRemove is automatically called.
     * @param killNow Remove the entity immediately when true; otherwise mark it
     * for removal at the end of the frame.
     * @return This wrapper.
     */
    Entity@ Remove( bool killNow = false )
    {
        CBaseEntity@ entity = this.toEntity;

        if( entity !is null )
        {
            entity.UpdateOnRemove();

            if( killNow )
            {
                g_EntityFuncs.Remove( entity );
            }
            else
            {
                entity.pev.flags |= FL_KILLME;
            }
        }
        return this;
    }

    /**
     * @brief Check whether the internal entity handle is still valid.
     * @return True when the wrapped entity still exists.
     */
    bool get_Valid() property
    {
        if( !this.m_EHandle.IsValid() )
        {
            // Clear all handles before accessing to them or the game will crash by invalid memory corruption.
            this.Clear();
            return false;
        }
        return true;
    }

    /**
     * @brief Get the internal entity handle.
     * @return The stored entity handle.
     */
    EHandle get_toHandle() property
    {
        this.Valid;
        return this.m_EHandle;
    }

    /**
     * @brief Resolve the wrapped entity interface.
     * @return The wrapped entity, or null when the handle is invalid.
     */
    CBaseEntity@ get_toEntity() property
    {
        if( this.Valid && this.m_CBaseEntity is null )
        {
            @this.m_CBaseEntity = this.m_EHandle.GetEntity();
        }
        return this.m_CBaseEntity;
    }

    /**
     * @brief Get the wrapped entity's edict index.
     * @return The edict index, or -1 when the handle is invalid.
     */
    int get_Index() property
    {
        if( this.toEntity !is null )
        {
            return this.toEntity.entindex();
        }
        return -1;
    }

    /**
     * @brief Get the wrapped entity's edict.
     * @return The entity edict, or null when the handle is invalid.
     */
    edict_t@ get_toEdict() property
    {
        if( this.Valid && this.m_edict is null )
        {
            @this.m_edict = this.m_CBaseEntity.edict();
        }
        return this.m_edict;
    }

    /**
     * @brief Get the wrapped entity's variables.
     * @return The entity variables, or null when the handle is invalid.
     */
    entvars_t@ get_toEntvars() property
    {
        if( this.Valid && this.m_entvars is null )
        {
            @this.m_entvars = this.m_CBaseEntity.pev;
        }
        return this.m_entvars;
    }

    /**
     * @brief Resolve the wrapped entity as a monster.
     * @return The monster interface, or null when the entity is not a monster.
     */
    CBaseMonster@ get_toMonster() property
    {
        if( this.Valid && this.m_CBaseMonster is null )
        {
            @this.m_CBaseMonster = cast<CBaseMonster@>( this.m_EHandle.GetEntity() );
        }
        return this.m_CBaseMonster;
    }

    /**
     * @brief Resolve the wrapped entity as a player.
     * @return The player interface, or null when the entity is not a player.
     */
    CBasePlayer@ get_toPlayer() property
    {
        if( this.Valid && this.m_CBasePlayer is null )
        {
            @this.m_CBasePlayer = cast<CBasePlayer@>( this.m_EHandle.GetEntity() );
        }
        return this.m_CBasePlayer;
    }

    /**
     * @brief Resolve the wrapped entity as a delayed entity.
     * @return The delayed entity interface, or null when unavailable.
     */
    CBaseDelay@ get_toDelay() property
    {
        if( this.Valid && this.m_CBaseDelay is null )
        {
            @this.m_CBaseDelay = cast<CBaseDelay@>( this.m_EHandle.GetEntity() );
        }
        return this.m_CBaseDelay;
    }

    /**
     * @brief Resolve the wrapped entity as an animating entity.
     * @return The animating entity interface, or null when unavailable.
     */
    CBaseAnimating@ get_toAnimating() property
    {
        if( this.Valid && this.m_CBaseAnimating is null )
        {
            @this.m_CBaseAnimating = cast<CBaseAnimating@>( this.m_EHandle.GetEntity() );
        }
        return this.m_CBaseAnimating;
    }

    /**
     * @brief Resolve the wrapped entity as a toggle entity.
     * @return The toggle entity interface, or null when unavailable.
     */
    CBaseToggle@ get_toToggle() property
    {
        if( this.Valid && this.m_CBaseToggle is null )
        {
            @this.m_CBaseToggle = cast<CBaseToggle@>( this.m_EHandle.GetEntity() );
        }
        return this.m_CBaseToggle;
    }

    /**
     * @brief Resolve the wrapped entity as a player item.
     * @return The player item interface, or null when unavailable.
     */
    CBasePlayerItem@ get_toPlayerItem() property
    {
        if( this.Valid && this.m_CBasePlayerItem is null )
        {
            @this.m_CBasePlayerItem = cast<CBasePlayerItem@>( this.m_EHandle.GetEntity() );
        }
        return this.m_CBasePlayerItem;
    }

    /**
     * @brief Resolve the wrapped entity as a player weapon.
     * @return The player weapon interface, or null when unavailable.
     */
    CBasePlayerWeapon@ get_toPlayerWeapon() property
    {
        if( this.Valid && this.m_CBasePlayerWeapon is null )
        {
            @this.m_CBasePlayerWeapon = cast<CBasePlayerWeapon@>( this.m_EHandle.GetEntity() );
        }
        return this.m_CBasePlayerWeapon;
    }

    /**
     * @brief Resolve the wrapped entity as player ammunition.
     * @return The player ammunition interface, or null when unavailable.
     */
    CBasePlayerAmmo@ get_toPlayerAmmo() property
    {
        if( this.Valid && this.m_CBasePlayerAmmo is null )
        {
            @this.m_CBasePlayerAmmo = cast<CBasePlayerAmmo@>( this.m_EHandle.GetEntity() );
        }
        return this.m_CBasePlayerAmmo;
    }

    /**
     * @brief Resolve the wrapped entity as an inventory item.
     * @return The inventory interface, or null when unavailable.
     */
    CItemInventory@ get_toItemInventory() property
    {
        if( this.Valid && this.m_ItemInventory is null )
        {
            @this.m_ItemInventory = cast<CItemInventory@>( this.m_EHandle.GetEntity() );
        }
        return this.m_ItemInventory;
    }

    /**
     * @brief Resolve the wrapped entity as an item.
     * @return The item interface, or null when unavailable.
     */
    CItem@ get_toItem() property
    {
        if( this.Valid && this.m_Item is null )
        {
            @this.m_Item = cast<CItem@>( this.m_EHandle.GetEntity() );
        }
        return this.m_Item;
    }

    /**
     * @brief Resolve the wrapped entity as a grenade.
     * @return The grenade interface, or null when unavailable.
     */
    CGrenade@ get_toGrenade() property
    {
        if( this.Valid && this.m_Grenade is null )
        {
            @this.m_Grenade = cast<CGrenade@>( this.m_EHandle.GetEntity() );
        }
        return this.m_Grenade;
    }

    /**
     * @brief Resolve the wrapped entity as a cinematic monster.
     * @return The cinematic monster interface, or null when unavailable.
     */
    CCineMonster@ get_toCineMonster() property
    {
        if( this.Valid && this.m_CBaseCineMonster is null )
        {
            @this.m_CBaseCineMonster = cast<CCineMonster@>( this.m_EHandle.GetEntity() );
        }
        return this.m_CBaseCineMonster;
    }

    /**
     * @brief Resolve the wrapped entity as a sprite.
     * @return The sprite interface, or null when unavailable.
     */
    CSprite@ get_toSprite() property
    {
        if( this.Valid && this.m_Sprite is null )
        {
            @this.m_Sprite = cast<CSprite@>( this.m_EHandle.GetEntity() );
        }
        return this.m_Sprite;
    }

    /**
     * @brief Resolve the wrapped entity as a path track.
     * @return The path track interface, or null when unavailable.
     */
    CPathTrack@ get_toPathTrack() property
    {
        if( this.Valid && this.m_PathTrack is null )
        {
            @this.m_PathTrack = cast<CPathTrack@>( this.m_EHandle.GetEntity() );
        }
        return this.m_PathTrack;
    }

    /**
     * @brief Resolve the wrapped entity as a beam.
     * @return The beam interface, or null when unavailable.
     */
    CBeam@ get_toBeam() property
    {
        if( this.Valid && this.m_Beam is null )
        {
            @this.m_Beam = cast<CBeam@>( this.m_EHandle.GetEntity() );
        }
        return this.m_Beam;
    }

    /**
     * @brief Resolve the wrapped entity as a laser.
     * @return The laser interface, or null when unavailable.
     */
    CLaser@ get_toLaser() property
    {
        if( this.Valid && this.m_Laser is null )
        {
            @this.m_Laser = cast<CLaser@>( this.m_EHandle.GetEntity() );
        }
        return this.m_Laser;
    }

    /**
     * @brief Resolve the wrapped entity as a tank.
     * @return The tank interface, or null when unavailable.
     */
    CBaseTank@ get_toTank() property
    {
        if( this.Valid && this.m_CBaseTank is null )
        {
            @this.m_CBaseTank = cast<CBaseTank@>( this.m_EHandle.GetEntity() );
        }
        return this.m_CBaseTank;
    }

#if DUMBSNIPER
    /**
     * @brief Resolve the wrapped entity as a path condition.
     * @return The path condition interface, or null when unavailable.
     */
    CPathCondition@ get_toPathCondition() property
    {
        if( this.Valid && this.m_CBasePathCondition is null )
        {
//  No conversion from 'CBaseEntity@&' to 'CPathCondition@' available.
// How dumb could someone be to expose a ent and not provide any way to use it? XDDDD
            @this.m_CBasePathCondition = cast<CPathCondition@>( this.m_EHandle.GetEntity() );
        }
        return this.m_CBasePathCondition;
    }
#endif

    /**
     * @brief Resolve the wrapped entity as a button.
     * @return The button interface, or null when unavailable.
     */
    CBaseButton@ get_toButton() property
    {
        if( this.Valid && this.m_CBaseButton is null )
        {
            @this.m_CBaseButton = cast<CBaseButton@>( this.m_EHandle.GetEntity() );
        }
        return this.m_CBaseButton;
    }

    /**
     * @brief Resolve the wrapped entity as a door.
     * @return The door interface, or null when unavailable.
     */
    CBaseDoor@ get_toDoor() property
    {
        if( this.Valid && this.m_CBaseDoor is null )
        {
            @this.m_CBaseDoor = cast<CBaseDoor@>( this.m_EHandle.GetEntity() );
        }
        return this.m_CBaseDoor;
    }

    /**
     * @brief Resolve the wrapped entity as a gib.
     * @return The gib interface, or null when unavailable.
     */
    CGib@ get_toGib() property
    {
        if( this.Valid && this.m_Gib is null )
        {
            @this.m_Gib = cast<CGib@>( this.m_EHandle.GetEntity() );
        }
        return this.m_Gib;
    }

    /**
     * @brief Resolve the wrapped entity as a custom script entity.
     * @return The custom script interface, or null when unavailable.
     */
    ScriptClassInterface@ get_toCustomEntity() property
    {
        if( this.Valid && this.m_ScriptClass is null )
        {
            @this.m_ScriptClass = CastToScriptClass( this.m_EHandle.GetEntity() );
        }
        return this.m_ScriptClass;
    }

    CBaseEntity@ opImplConv()
    {
        return this.toEntity;
    }

    edict_t@ opImplConv()
    {
        return this.toEdict;
    }

    entvars_t@ opImplConv()
    {
        return this.toEntvars;
    }

    CBaseMonster@ opImplConv()
    {
        return this.toMonster;
    }

    CBasePlayer@ opImplConv()
    {
        return this.toPlayer;
    }

    CBaseDelay@ opImplConv()
    {
        return this.toDelay;
    }

    CBaseAnimating@ opImplConv()
    {
        return this.toAnimating;
    }

    CBaseToggle@ opImplConv()
    {
        return this.toToggle;
    }

    CBasePlayerItem@ opImplConv()
    {
        return this.toPlayerItem;
    }

    CBasePlayerWeapon@ opImplConv()
    {
        return this.toPlayerWeapon;
    }

    CBasePlayerAmmo@ opImplConv()
    {
        return this.toPlayerAmmo;
    }

    CItemInventory@ opImplConv()
    {
        return this.toItemInventory;
    }

    CItem@ opImplConv()
    {
        return this.toItem;
    }

    CGrenade@ opImplConv()
    {
        return this.toGrenade;
    }

    CCineMonster@ opImplConv()
    {
        return this.toCineMonster;
    }

    CSprite@ opImplConv()
    {
        return this.toSprite;
    }

    CPathTrack@ opImplConv()
    {
        return this.toPathTrack;
    }

    CBeam@ opImplConv()
    {
        return this.toBeam;
    }

    CLaser@ opImplConv()
    {
        return this.toLaser;
    }

    CBaseTank@ opImplConv()
    {
        return this.toTank;
    }

#if DUMBSNIPER
    CPathCondition@ opImplConv()
    {
        return this.toPathCondition;
    }
#endif

    CBaseButton@ opImplConv()
    {
        return this.toButton;
    }

    CBaseDoor@ opImplConv()
    {
        return this.toDoor;
    }

    CGib@ opImplConv()
    {
        return this.toGib;
    }
}
