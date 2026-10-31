#include "v2"
#include "v2/time"
#include "v2/json/v1"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk155" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );
    g_Scheduler.SetTimeout( "StupidSpam", 0.01f );
}

void StupidSpam()
{
    // Configure
    Logger::Config
        .SetCallback(
            function( string&in message, const Logger::Level&in level ) {
                Logger::time::format( message, message );
                g_Game.AlertMessage( at_console, message );
                return true;
            }
        )
        .SetGlobalName( g_Module.GetModuleName() );

    weakref<Logger> logger_Ref = Logger::Global();
    Logger@ logger = logger_Ref.get();
//    Logger::SetStateAll( true, true );

    Logger::json::v1::configure( """{
"global": {
    "info": true
}
}""" );

    if( logger !is null )
    {
        logger.info( "single message" );
        logger.info( "message with *args: {} {}!", { "Hello", "world" } );
        logger.info( "message with *kwargs: {h} {w}!", null, { { "h", "Hello" }, { "w", "world" } } );
        logger.info( "message with *args & *kwargs: {} {w}{}", { "Hello", "!" }, { { "w", "world" } } );
    }
}
