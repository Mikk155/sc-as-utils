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
    array<CollectedHook@> GiveItemCollectedHooks(0);

    /**
    * @brief Give an already-created weapon, ammo entity, or item to a player.
    *
    * CBasePlayer::GiveNamedItem cannot force a weapon to be equipped
    * This overload instead uses the entity's touch behavior, so it can give initialized entities directly.
    *
    * CBasePlayer::GiveNamedItem using SF_GIVENITEM prevents CollectedHook from being called.
    * CollectedHook and CanCollectHook are not called for item_inventory.
    * there's nothing we can do about that. you can insert a pointer
    * to your hook in Player::GiveItemCollectedHooks and we call it. CanCollectHook however can't be called
    * due to language limitations with bool&out result. The sven coop developers should provide decent API.
    *
    * @param player Player receiving the entity.
    * @param entity Initialized weapon, ammo, or item entity to give.
    * @param deleteEntity Remove the entity when the existing give logic would
    *        remove it. Defaults to true.
    * @param forceWeaponEquip Force the weapon pickup/equip behavior. Defaults
    *        to true. This uses CBasePlayer::SetItemPickupTimes
    */
    void GiveItem( CBasePlayer@ player, CBaseEntity@ entity, bool deleteEntity = true, bool forceWeaponEquip = true )
    {
        CBasePlayerWeapon@ weapon;
        CItem@ item;
        CItemInventory@ itemInventory;
        CBasePlayerAmmo@ ammo;

        if( ( @weapon = cast<CBasePlayerWeapon@>( entity ) ) is null
        && ( @ammo = cast<CBasePlayerAmmo@>( entity ) ) is null
        && ( @itemInventory = cast<CItemInventory@>( entity ) ) is null
        && ( @item = cast<CItem@>( entity ) ) is null )
            return;

        if( weapon !is null )
        {
            if( forceWeaponEquip )
                player.SetItemPickupTimes( g_Engine.time );

            weapon.Touch(player);

            // Dont kill weapons since they're pass onto the player
            if( weapon.pev.movetype == MOVETYPE_FOLLOW )
            {
                deleteEntity = false;
            }
        }
        else if( ammo !is null )
        {
            ammo.Touch(player);
        }
        else if( item !is null )
        {
            item.Touch(player);
        }
        else
        {
            entity.Touch( player );
        }

        if( itemInventory !is null )
        {
            const uint length = GiveItemCollectedHooks.length();

            for( uint ui = 0; ui < length; ui++ )
            {
                auto pHook = GiveItemCollectedHooks[ui];

                if( pHook !is null )
                {
                    pHook( entity, player );
                }
            }
        }

        if( deleteEntity )
        {
            g_EntityFuncs.Remove( entity );
        }
    }

    /**
    * @brief Create an item with optional custom keyvalues and give it to a player.
    *
    * CBasePlayer::GiveNamedItem does not provide an option to apply custom
    * keyvalues or to control weapon equipping. This overload creates and
    * initializes the entity first, then gives it through the initialized-entity
    * overload so those options remain available.
    *
    * CBasePlayer::GiveNamedItem cannot force a weapon to be equipped
    * This overload instead uses the entity's touch behavior, so it can give initialized entities directly.
    *
    * CBasePlayer::GiveNamedItem using SF_GIVENITEM prevents CollectedHook from being called.
    * CollectedHook and CanCollectHook are not called for item_inventory.
    * there's nothing we can do about that. you can insert a pointer
    * to your hook in Player::GiveItemCollectedHooks and we call it. CanCollectHook however can't be called
    * due to language limitations with bool&out result. The sven coop developers should provide decent API.
    *
    * @param player Player receiving the created entity.
    * @param classname Classname of the entity to create.
    * @param keyvalues Optional custom keyvalues applied when creating the entity.
    * @param deleteEntity Remove the entity when the existing give logic would
    *        remove it. Defaults to true.
    * @param forceWeaponEquip Force the weapon pickup/equip behavior. Defaults
    *        to true. This uses CBasePlayer::SetItemPickupTimes
    */
    void GiveItem( CBasePlayer@ player, const string&in classname, dictionary@ keyvalues = null, bool deleteEntity = true, bool forceWeaponEquip = true )
    {
        CBaseEntity@ entity = g_EntityFuncs.CreateEntity( classname, keyvalues, false );
        entity.pev.spawnflags |= SF_NORESPAWN;
        g_EntityFuncs.DispatchSpawn( entity.edict() );
        g_EntityFuncs.SetOrigin( entity, player.pev.origin );
        GiveItem( player, entity, deleteEntity, forceWeaponEquip );
    }
}
