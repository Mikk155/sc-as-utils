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

#include "v2"
#include "../String/bool"
#include "../Entity/Entity"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk155" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    Logger::Config.SetGlobalName( g_Module.GetModuleName() ).SetCallback(
        function( string&in message, const Logger::Level&in level ) {
            g_EngineFuncs.ServerPrint( message );
            return true;
        }
    );

    weakref<Logger> logger_Ref = Logger::Global();
    @logger = logger_Ref.get();
    Logger::SetStateAll( true, true );

    g_Scheduler.SetTimeout( "StupidSpam", 0.01f );
}

Logger@ logger;

void StupidSpam()
{
    auto ent = g_EntityFuncs.Create( "monster_snark", g_vecZero, g_vecZero, false, null );

    Entity@ e1 = ent;
    logger.info( "Entity@ e1 = {}", ( e1.toEntity !is null ? string(e1.toEntvars.classname) : "null" ) );

    e1 = ent;
    logger.info( "e1 = {}", ( e1.toEntity !is null ? string(e1.toEntvars.classname) : "null" ) );

    @e1 = ent;
    logger.info( "@e1 = {}", ( e1.toEntity !is null ? string(e1.toEntvars.classname) : "null" ) );

    Entity e2 = ent;
    logger.info( "Entity e2 = {}", ( e2.toEntity !is null ? string(e2.toEntvars.classname) : "null" ) );

    e2 = ent;
    logger.info( "e2 = {}", ( e2.toEntity !is null ? string(e2.toEntvars.classname) : "null" ) );

    logger.info( "@e2 = {} | crash, expected." );

    e2 = e1;
    logger.info( "e2 = e1 ({})", ( e2.toEntity !is null ? string(e2.toEntvars.classname) : "null" ) );

    e1 = e2;
    logger.info( "e1 = e2 ({})", ( e1.toEntity !is null ? string(e1.toEntvars.classname) : "null" ) );

    Entity@ e3 = e1;
    logger.info( "Entity@ e3 = e1 ({})", ( e3.toEntity !is null ? string(e3.toEntvars.classname) : "null" ) );

    @e3 = null;
    logger.info( "@e3 = null ({})", ( e3 !is null ? string(e3.toEntvars.classname) : "null" ) );

    e2 = null;
    logger.info( "e2 = null ({})", ( e3 !is null ? string(e3.toEntvars.classname) : "null" ) );

    Entity@ e4 = null;
    logger.info( "Entity@ e4 = null ({})", { e4 is null } );

    Entity@ a = ent;
    Entity@ b = null;
    logger.info( "( Entity(ent) !is Entity(null) ) {}", String::from_bool( a !is b ) );
    logger.info( "( Entity(ent) is Entity(null) ) {}", String::from_bool( a is b ) );
    logger.info( "( Entity(ent) !is null ) {}", String::from_bool( a !is null ) );
    logger.info( "( Entity(ent) is null ) {}", String::from_bool( a is null ) );
    logger.info( "( Entity(ent) !is Entity(ent) ) {}", String::from_bool( a !is Entity(ent) ) );
    logger.info( "( Entity(ent) is Entity(ent) ) {}", String::from_bool( a is Entity(ent) ) );
    logger.info( "( Entity(ent) == Entity(ent) ) {}", String::from_bool( a == Entity(ent) ) );
    logger.info( "( Entity(ent) != Entity(ent) ) {}", String::from_bool( a != Entity(ent) ) );

    EHandle handle = a;
    CBaseEntity@ entity = a;
    CBaseAnimating@ animating = a;
    g_Scheduler.SetTimeout( "ScheduledTask", 0.1f, a );
}

void ScheduledTask( Entity&in entity )
{
    logger.info( "Scheduled Entity = {}", ( entity.toEntity !is null ? string(entity.toEntvars.classname) : "null" ) );

    if( entity.toEntity !is null )
    {
        entity.Remove();
        g_Scheduler.SetTimeout( "ScheduledTask", 0.1f, entity );
    }
}
